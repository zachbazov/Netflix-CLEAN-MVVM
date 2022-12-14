//
//  NetworkService.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - NetworkError Type

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

// MARK: - NetworkCancellable Protocol

protocol NetworkCancellable {
    func cancel()
}

// MARK: - URLSessionTask Extension

extension URLSessionTask: NetworkCancellable {}

// MARK: - NetworkServiceInput Protocol

protocol NetworkServiceInput {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(endpoint: Requestable,
                 completion: @escaping CompletionHandler) -> NetworkCancellable?
}

// MARK: - NetworkSessionManagerInput Protocol

protocol NetworkSessionManagerInput {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
}

// MARK: - NetworkErrorLoggerInput Protocol

private protocol NetworkErrorLoggerInput {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

// MARK: - NetworkService Type

struct NetworkService {
    let config: NetworkConfigurable
    let sessionManager = NetworkSessionManager()
    let logger = NetworkErrorLogger()
}

// MARK: - Methods

extension NetworkService {
    private func request(request: URLRequest,
                         completion: @escaping CompletionHandler) -> NetworkCancellable {
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            if let requestError = requestError {
                var error: NetworkError
                
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
        
        logger.log(request: request)
        
        return sessionDataTask
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

// MARK: - NetworkServiceInput Implementation

extension NetworkService: NetworkServiceInput {
    func request(endpoint: Requestable,
                 completion: @escaping CompletionHandler) -> NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}

// MARK: - NetworkSessionManager Type

struct NetworkSessionManager: NetworkSessionManagerInput {
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

// MARK: - NetworkErrorLogger Type

struct NetworkErrorLogger: NetworkErrorLoggerInput {
    func log(request: URLRequest) {
        printIfDebug("-------------")
        printIfDebug("request: \(request.url!)")
        printIfDebug("headers: \(request.allHTTPHeaderFields!)")
        printIfDebug("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody,
           let json = (try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]),
           let result = json as [String: AnyObject]? {
            printIfDebug("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("body: \(String(describing: resultString))")
        }
    }
    
    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        
        if let dataDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//            printIfDebug("responseData: \(String(describing: dataDict))")
            printIfDebug("response: \(dataDict["status"]!)")
        }
    }
    
    func log(error: Error) { printIfDebug("\(error)") }
}

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

// MARK: - NetworkCancellable Type

protocol NetworkCancellable {
    func cancel()
}

// MARK: - NetworkCancellable Implementation

extension URLSessionTask: NetworkCancellable {}

// MARK: - NetworkServiceInput Type

protocol NetworkServiceInput {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable?
    
    func request(endpoint: Requestable) async throws -> (Data, URLResponse)?
}

// MARK: - NetworkSessionManagerInput Type

protocol NetworkSessionManagerInput {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable
    
    func request(_ request: URLRequest) async throws -> (Data, URLResponse)?
}

// MARK: - NetworkErrorLoggerInput Type

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
    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
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
    
    private func request(request: URLRequest) async throws -> (Data, URLResponse)? {
        self.logger.log(request: request)
        guard let (data, response) = try await sessionManager.request(request) else { return nil }
        self.logger.log(responseData: data, response: response)
        return (data, response)
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
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
    
    func request(endpoint: Requestable) async throws -> (Data, URLResponse)? {
        let urlRequest = try await endpoint.urlRequest(with: config)
        guard let (data, response) = try await self.request(request: urlRequest) else { return nil }
        return (data, response)
    }
}

// MARK: - NetworkSessionManager Type

struct NetworkSessionManager: NetworkSessionManagerInput {
    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
    
    func request(_ request: URLRequest) async throws -> (Data, URLResponse)? {
        return try await URLSession.shared.data(for: request)
    }
}

// MARK: - NetworkErrorLogger Type

struct NetworkErrorLogger: NetworkErrorLoggerInput {
    func log(request: URLRequest) {
        printIfDebug(.linebreak, "-------------")
        printIfDebug(.network, "request: \(request.url!)")
        printIfDebug(.network, "headers: \(request.allHTTPHeaderFields!)")
        printIfDebug(.network, "method: \(request.httpMethod!)")
        if let httpBody = request.httpBody,
           let json = (try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]),
           let result = json as [String: AnyObject]? {
            printIfDebug(.network, "body: \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug(.network, "body: \(String(describing: resultString))")
        }
    }
    
    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        
        if let dataDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//            printIfDebug("responseData: \(String(describing: dataDict))")
            printIfDebug(.network, "response: \(dataDict["status"]!)")
        }
    }
    
    func log(error: Error) { printIfDebug(.error, "\(error)") }
}

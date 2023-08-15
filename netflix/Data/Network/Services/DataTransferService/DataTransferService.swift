//
//  DataTransferService.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - DataServiceTransferable Type

protocol DataServiceTransferable {
    var dataTransferService: DataServiceTransferring { get }
}

// MARK: - DataTransferError Type

enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworlFailure(Error)
}

// MARK: - DataServiceTransferring Type

protocol DataServiceTransferring {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>) -> NetworkCancellable? where E.Response == Void
}

// MARK: - DataTransferErrorResolverProtocol Type

protocol DataTransferErrorResolverProtocol {
    func resolve(error: NetworkError) -> Error
}

// MARK: - ResponseDecoder Type

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

// MARK: - DataTransferErrorLoggerProtocol Type

protocol DataTransferErrorLoggerProtocol {
    func log(error: Error)
}

// MARK: - DataTransferService Type

struct DataTransferService {
    let networkService: NetworkService
    let errorResolver = DataTransferErrorResolver()
    let errorLogger = DataTransferErrorLogger()
}

// MARK: - DataServiceTransferring Implementation

extension DataTransferService: DataServiceTransferring {
    func request<T, E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where T: Decodable, E: ResponseRequestable, T == E.Response {
        
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                mainQueueDispatch {
                    return completion(result)
                }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                mainQueueDispatch {
                    return completion(.failure(error))
                }
            }
        }
    }
    
    func request<E>(with endpoint: E,
                    completion: @escaping (Result<Void, DataTransferError>) -> Void) -> NetworkCancellable? where E: ResponseRequestable, E.Response == Void {
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                mainQueueDispatch {
                    return completion(.success(()))
                }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                mainQueueDispatch {
                    return completion(.failure(error))
                }
            }
        }
    }
    
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworlFailure(resolvedError)
    }
}

// MARK: - DataTransferErrorLogger Type

struct DataTransferErrorLogger: DataTransferErrorLoggerProtocol {
    func log(error: Error) {
        printIfDebug(.none, "------------")
        printIfDebug(.error, "\(error)")
    }
}

// MARK: - DataTransferErrorResolver Type

struct DataTransferErrorResolver: DataTransferErrorResolverProtocol {
    func resolve(error: NetworkError) -> Error { error }
}

// MARK: - JSONResponseDecoder Type

public class JSONResponseDecoder: ResponseDecoder {
    private let decoder = JSONDecoder()
    public init() {}
    func decode<T>(_ data: Data) throws -> T where T: Decodable {
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - RawDataResponseDecoder Type

public class RawDataResponseDecoder: ResponseDecoder {
    public init() {}
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default],
                                                debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}

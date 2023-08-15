//
//  UseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - NetworkRequestable Type

protocol NetworkRequestable {
    associatedtype E
    
    func request<T>(endpoint: E,
                    for response: T.Type,
                    request: Any?,
                    cached: @escaping (T?) -> Void,
                    completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    
//    func request<T>(endpoint: E, for response: T.Type, request: Any?) async -> T? where T: Decodable
}

// MARK: - UseCase Type

protocol UseCase: NetworkRequestable {
    associatedtype RepositoryType: Repository
    
    var repository: RepositoryType { get }
}

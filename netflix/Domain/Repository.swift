//
//  Repository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - RepositoryRequestable Type

protocol RepositoryRequestable {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    func create<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    func update<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    func delete<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    
    func find<T>(request: Any?) async -> T? where T: Decodable
    func create<T>(request: Any?) async -> T? where T: Decodable
    func update<T>(request: Any?) async -> T? where T: Decodable
    func delete<T>(request: Any?) async -> T? where T: Decodable
}

// MARK: - RepositoryRequestable Implementation

extension RepositoryRequestable {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func create<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func update<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func delete<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func find<T>(request: Any?) async -> T? where T: Decodable {
        return nil
    }
    
    func create<T>(request: Any?) async -> T? where T: Decodable {
        return nil
    }
    
    func update<T>(request: Any?) async -> T? where T: Decodable {
        return nil
    }
    
    func delete<T>(request: Any?) async -> T? where T: Decodable {
        return nil
    }
}

// MARK: - Taskable Type

protocol Taskable {
    var task: Cancellable? { get }
}

// MARK: - Repository Type

protocol Repository: Taskable, DataServiceTransferable, RepositoryRequestable {}

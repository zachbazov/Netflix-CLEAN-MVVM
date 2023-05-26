//
//  RepositoryNetworking.swift
//  netflix
//
//  Created by Zach Bazov on 26/05/2023.
//

import Foundation

// MARK: - RequestInvoking Type

protocol RequestInvoking {
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    func getAll<T, U>(request: U,
                      completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    func createOne<T, U>(request: U,
                         completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    func updateOne<T, U>(request: U,
                         completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    func deleteAll<T>(completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable
    func deleteOne<T, U>(request: U,
                         completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    
    func getAll<T>() async -> T? where T: Decodable
    func getAll<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
    func getOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
    func createOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
    func updateOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
    func deleteAll<T>() async -> T? where T: Decodable
    func deleteOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
}

// MARK: - RequestInvoking Implementation

extension RequestInvoking {
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func getAll<T, U>(request: U,
                      completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
    
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
    
    func createOne<T, U>(request: U,
                         completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
    
    func updateOne<T, U>(request: U,
                         completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
    
    func deleteAll<T>(completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func deleteOne<T, U>(request: U,
                         completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
    
    func getAll<T>() async -> T? where T: Decodable {
        return nil
    }
    
    func getAll<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        return nil
    }
    
    func getOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        return nil
    }
    
    func createOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        return nil
    }
    
    func updateOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        return nil
    }
    
    func deleteAll<T>() async -> T? where T: Decodable {
        return nil
    }
    
    func deleteOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        return nil
    }
}

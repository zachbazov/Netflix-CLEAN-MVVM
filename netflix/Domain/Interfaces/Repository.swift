//
//  Repository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Repository Type

protocol Repository {
    var dataTransferService: DataTransferService { get }
    var task: Cancellable? { get set }
    
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    func updateOne<T, U>(request: U,
                         completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    
    func getAll<T>() async -> T? where T: Decodable
    func getOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
    func updateOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable
}

// MARK: - Default Implementation

extension Repository {
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable { return nil }
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable { return nil }
    func updateOne<T, U>(request: U,
                         completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable { return nil }
    
    func getAll<T>() async -> T? where T: Decodable { return nil }
    func getOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable { return nil }
    func updateOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable { return nil }
}

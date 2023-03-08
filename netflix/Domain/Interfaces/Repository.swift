//
//  Repository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Repository Type

protocol RepositoryInput {
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable
    
    func getAll<T>() async -> T? where T: Decodable
}

protocol RepositoryOutput {
    var dataTransferService: DataTransferService { get }
    var task: Cancellable? { get set }
}

typealias Repository = RepositoryInput & RepositoryOutput

// MARK: - Default Implementation

extension RepositoryInput {
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable { return nil }
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable { return nil }
    
    func getAll<T>() async -> T? where T: Decodable { return nil }
}

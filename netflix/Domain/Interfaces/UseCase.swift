//
//  UseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - UseCase Type

protocol UseCaseInput {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable?
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable?
    
    func request<T>(for response: T.Type) async -> T? where T: Decodable
    func request<T, U>(for response: T.Type, request: U) async -> T? where T: Decodable
}

protocol UseCaseOutput {
    associatedtype T: Repository
    var repository: T { get }
}

typealias UseCase = UseCaseInput & UseCaseOutput

// MARK: - Default Implementation

extension UseCaseInput {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? { return nil }
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? { return nil }
    
    func request<T>(for response: T.Type) async -> T? where T: Decodable { return nil }
    func request<T, U>(for response: T.Type, request: U) async -> T? where T: Decodable { return nil }
}

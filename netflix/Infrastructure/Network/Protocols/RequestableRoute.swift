//
//  RequestableRoute.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - RequestableRoute Type

protocol RequestableRoute {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable?
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable?
    
    func request<T>(for response: T.Type) async -> T?
}

// MARK: - Default Implementation

extension RequestableRoute {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? { return nil }
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? { return nil }
    
    func request<T>(for response: T.Type) async -> T? { return nil }
}

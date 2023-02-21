//
//  AuthRepositoryProtocol.swift
//  netflix
//
//  Created by Zach Bazov on 03/02/2023.
//

import Foundation

// MARK: - AuthRepositoryProtocol Type

protocol AuthRepositoryProtocol {
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signIn(request: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable?
}

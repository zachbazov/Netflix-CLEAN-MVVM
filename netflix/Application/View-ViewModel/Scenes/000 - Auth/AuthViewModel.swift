//
//  AuthViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func signUp(requestDTO: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void)
    func signIn(requestDTO: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void)
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void)
}

private protocol ViewModelOutput {
    var useCase: UserUseCase { get }
}

private typealias ViewModelProtocol = ViewModelInput

// MARK: - AuthViewModel Type

final class AuthViewModel {
    var coordinator: AuthCoordinator?
    private let useCase = UserUseCase()
}

// MARK: - ViewModel Implementation

extension AuthViewModel: ViewModel {}

// MARK: - Coordinable Implementation

extension AuthViewModel: Coordinable {}

// MARK: - ViewModelProtocol Implementation

extension AuthViewModel: ViewModelProtocol {
    /// Sign up a user.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - completion: Completion handler with a response.
    func signUp(requestDTO: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(for: UserHTTPDTO.Response.self,
                                                  request: requestDTO,
                                                  cached: nil,
                                                  completion: completion)
    }
    /// Sign in a user.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - cached: Cached authorization handler.
    ///   - completion: Authorization completion handler.
    func signIn(requestDTO: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(for: UserHTTPDTO.Response.self,
                                                  request: requestDTO,
                                                  cached: cached,
                                                  completion: completion)
    }
    /// Sign out a user.
    /// - Parameter completion: Completion handler with a result object.
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(for: Void.self,
                                                  request: Void.self,
                                                  cached: nil,
                                                  completion: completion)
    }
}

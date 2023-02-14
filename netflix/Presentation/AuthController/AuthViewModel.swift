//
//  AuthViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - AuthViewModel Type

final class AuthViewModel {
    var coordinator: AuthCoordinator?
    private let useCase = AuthUseCase()
}

// MARK: - ViewModel's Implementation

extension AuthViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - AuthUseCase Implementation

extension AuthViewModel {
    /// Sign up a user.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - completion: Completion handler with a response.
    func signUp(requestDTO: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.router.request(for: UserHTTPDTO.Response.self,
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
        useCase.repository.task = useCase.router.request(for: UserHTTPDTO.Response.self,
                                                         request: requestDTO,
                                                         cached: cached,
                                                         completion: completion)
    }
    /// Sign out a user.
    /// - Parameter completion: Completion handler with a result object.
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.router.request(for: Void.self,
                                                         request: Void.self,
                                                         cached: nil,
                                                         completion: completion)
    }
}

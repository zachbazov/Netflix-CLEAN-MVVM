//
//  AuthViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - AuthViewModel Type

final class AuthViewModel {
    
    // MARK: ViewModel's Properties
    
    var coordinator: AuthCoordinator?
    
    // MARK: Type's Properties
    
    private let useCase: AuthUseCase
    private var authorizationTask: Cancellable? { willSet { authorizationTask?.cancel() } }
    
    // MARK: Initializer
    
    /// Default initializer.
    /// Allocate `useCase` property and it's dependencies.
    init() {
        let dataTransferService = Application.current.dataTransferService
        let authResponseCache = Application.current.authResponseCache
        let authRepository = AuthRepository(dataTransferService: dataTransferService, cache: authResponseCache)
        self.useCase = AuthUseCase(authRepository: authRepository)
    }
    
    // MARK: Deinitializer
    
    deinit {
        coordinator = nil
        authorizationTask = nil
    }
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
    func signUp(request: AuthRequest,
                completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        let requestValue = AuthUseCaseRequestValue(method: .signup, request: request)
        authorizationTask = useCase.execute(requestValue: requestValue, completion: completion)
    }
    /// Sign in a user.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - cached: Cached authorization handler.
    ///   - completion: Authorization completion handler.
    func signIn(request: AuthRequest,
                cached: @escaping (AuthResponseDTO?) -> Void,
                completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        let requestValue = AuthUseCaseRequestValue(method: .signin, request: request)
        authorizationTask = useCase.execute(requestValue: requestValue, cached: cached, completion: completion)
    }
    /// Sign out a user.
    /// - Parameter completion: Completion handler with a result object.
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) {
        authorizationTask = useCase.execute(completion: completion)
    }
}

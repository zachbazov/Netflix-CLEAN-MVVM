//
//  AuthViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var useCase: UserUseCase { get }
    
    func signUp(requestDTO: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void)
    func signIn(requestDTO: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void)
    func signOut(completion: @escaping (Result<VoidHTTPDTO.Response, DataTransferError>) -> Void)
    
    func signUp(with request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signIn(with request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signOut(with request: UserHTTPDTO.Request) async -> VoidHTTPDTO.Response?
}

// MARK: - AuthViewModel Type

final class AuthViewModel {
    var coordinator: AuthCoordinator?
    
    fileprivate lazy var useCase: UserUseCase = createUseCase()
}

// MARK: - ViewModel Implementation

extension AuthViewModel: ViewModel {}

// MARK: - CoordinatorAssignable Implementation

extension AuthViewModel: CoordinatorAssignable {}

// MARK: - ViewModelProtocol Implementation

extension AuthViewModel: ViewModelProtocol {
    /// Sign up request.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - completion: Completion handler with a response.
    func signUp(requestDTO: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(endpoint: .signUp,
                                                  for: UserHTTPDTO.Response.self,
                                                  request: requestDTO,
                                                  cached: nil,
                                                  completion: completion)
    }
    
    /// Sign in request.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - cached: Cached authorization handler.
    ///   - completion: Authorization completion handler.
    func signIn(requestDTO: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(endpoint: .signIn,
                                                  for: UserHTTPDTO.Response.self,
                                                  request: requestDTO,
                                                  cached: cached,
                                                  completion: completion)
    }
    
    /// Sign out request.
    /// - Parameter completion: Completion handler with a result object.
    func signOut(completion: @escaping (Result<VoidHTTPDTO.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(endpoint: .signOut,
                                                  for: VoidHTTPDTO.Response.self,
                                                  request: VoidHTTPDTO.Response.self,
                                                  cached: nil,
                                                  completion: completion)
    }
    
    /// Asynchronous sign up request.
    /// - Parameter request: User's request object.
    /// - Returns: User's response object.
    func signUp(with request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        return await useCase.request(endpoint: .signUp, for: UserHTTPDTO.Response.self, request: request)
    }
    
    /// Asynchronous sign in request.
    /// - Parameter request: User's request object.
    /// - Returns: User's response object.
    func signIn(with request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        return await useCase.request(endpoint: .signIn, for: UserHTTPDTO.Response.self, request: request)
    }
    
    /// Asynchronous sign out request.
    /// - Parameter request: User's request object.
    /// - Returns: User's response object.
    func signOut(with request: UserHTTPDTO.Request) async -> VoidHTTPDTO.Response? {
        return await useCase.request(endpoint: .signOut, for: VoidHTTPDTO.Response.self, request: request)
    }
}

// MARK: - Private Implementation

extension AuthViewModel {
    private func createUseCase() -> UserUseCase {
        let services = Application.app.services
        let authService = services.auth
        let dataTransferService = services.dataTransfer
        let persistentStore = UserHTTPResponseStore(authService: authService)
        let authenticator = UserRepositoryAuthenticator(dataTransferService: dataTransferService, persistentStore: persistentStore)
        let invoker = RepositoryInvoker(dataTransferService: dataTransferService, persistentStore: persistentStore)
        let repository = UserRepository(dataTransferService: dataTransferService, authenticator: authenticator, persistentStore: persistentStore, invoker: invoker)
        return UserUseCase(repository: repository)
    }
}

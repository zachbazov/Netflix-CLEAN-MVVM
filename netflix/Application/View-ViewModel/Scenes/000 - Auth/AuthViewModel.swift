//
//  AuthViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func signUp(requestDTO: UserHTTPDTO.POST.Request,
                completion: @escaping (Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void)
    func signIn(requestDTO: UserHTTPDTO.POST.Request,
                cached: @escaping (UserHTTPDTO.POST.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void)
    func signOut(completion: @escaping (Result<VoidHTTP.Response, DataTransferError>) -> Void)
    
    func signUp(with request: UserHTTPDTO.POST.Request) async -> UserHTTPDTO.POST.Response?
    func signIn(with request: UserHTTPDTO.POST.Request) async -> UserHTTPDTO.POST.Response?
    func signOut(with request: UserHTTPDTO.GET.Request) async -> VoidHTTP.Response?
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
    /// Sign up request.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - completion: Completion handler with a response.
    func signUp(requestDTO: UserHTTPDTO.POST.Request,
                completion: @escaping (Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(endpoint: .signUp,
                                                  for: UserHTTPDTO.POST.Response.self,
                                                  request: requestDTO,
                                                  cached: nil,
                                                  completion: completion)
    }
    /// Sign in request.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - cached: Cached authorization handler.
    ///   - completion: Authorization completion handler.
    func signIn(requestDTO: UserHTTPDTO.POST.Request,
                cached: @escaping (UserHTTPDTO.POST.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(endpoint: .signIn,
                                                  for: UserHTTPDTO.POST.Response.self,
                                                  request: requestDTO,
                                                  cached: cached,
                                                  completion: completion)
    }
    /// Sign out request.
    /// - Parameter completion: Completion handler with a result object.
    func signOut(completion: @escaping (Result<VoidHTTP.Response, DataTransferError>) -> Void) {
        useCase.repository.task = useCase.request(endpoint: .signOut,
                                                  for: VoidHTTP.Response.self,
                                                  request: Void.self,
                                                  cached: nil,
                                                  completion: completion)
    }
    /// Asynchronous sign up request.
    /// - Parameter request: User's request object.
    /// - Returns: User's response object.
    func signUp(with request: UserHTTPDTO.POST.Request) async -> UserHTTPDTO.POST.Response? {
        return await useCase.request(endpoint: .signUp, for: UserHTTPDTO.POST.Response.self, request: request)
    }
    /// Asynchronous sign in request.
    /// - Parameter request: User's request object.
    /// - Returns: User's response object.
    func signIn(with request: UserHTTPDTO.POST.Request) async -> UserHTTPDTO.POST.Response? {
        return await useCase.request(endpoint: .signIn, for: UserHTTPDTO.POST.Response.self, request: request)
    }
    /// Asynchronous sign out request.
    /// - Parameter request: User's request object.
    /// - Returns: User's response object.
    func signOut(with request: UserHTTPDTO.GET.Request) async -> VoidHTTP.Response? {
        return await useCase.request(endpoint: .signOut, for: VoidHTTP.Response.self, request: request)
    }
}

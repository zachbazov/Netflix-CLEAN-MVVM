//
//  AuthUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - AuthUseCaseProtocol Protocol

private protocol AuthUseCaseProtocol {
    var authRepository: AuthRepository { get }
    
    func execute<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable?
}

// MARK: - AuthUseCase Type

final class AuthUseCase {
    fileprivate let authRepository: AuthRepository
    
    required init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
}

// MARK: - AuthUseCaseProtocol Implementation

extension AuthUseCase: AuthUseCaseProtocol {
    /// Send a task operation according to the parameters.
    /// In case data exists, exit the scope and execute the cached operation.
    /// In case data doesn't exist, exit the scope and execute the completion handler.
    /// - Parameters:
    ///   - response: Expected response type.
    ///   - request: Expected request type.
    ///   - cached: Cached operation, if exists.
    ///   - completion: Completion handler.
    /// - Returns: A task operation.
    private func request<T, U>(for response: T.Type,
                               request: U? = nil,
                               cached: ((T?) -> Void)?,
                               completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? {
        switch response {
        case is UserHTTPDTO.Response.Type:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            // In case there is data in the storage, perform a sign-in task.
            if let cached = cached as? ((UserHTTPDTO.Response?) -> Void) {
                return authRepository.signIn(request: request, cached: cached, completion: completion)
            }
            // In case there isn't, perform a sign-up task.
            return authRepository.signUp(request: request, completion: completion)
        case is Void.Type:
            // Perform a sign-out task.
            let completion = completion as? ((Result<Void, DataTransferError>) -> Void) ?? { _ in }
            return authRepository.signOut(completion: completion)
        default: return nil
        }
    }
    /// Execute a task operation.
    /// - Parameters:
    ///   - response: Expected response type.
    ///   - request: Expected request type.
    ///   - cached: Cached operation, if exists.
    ///   - completion: Completion handler.
    /// - Returns: A task operation.
    func execute<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? {
        return self.request(for: response,
                            request: request,
                            cached: cached,
                            completion: completion)
    }
}

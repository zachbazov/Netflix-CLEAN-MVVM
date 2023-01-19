//
//  AuthUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - AuthUseCaseRequestValue Type

struct AuthUseCaseRequestValue {
    var method: AuthMethod
    let request: AuthRequest
}

// MARK: - AuthMethod Type

enum AuthMethod {
    case signup
    case signin
    case signout
}

// MARK: - AuthUseCase Type

final class AuthUseCase {
    
    // MARK: Properties
    
    private let authRepository: AuthRepository
    
    // MARK: Initializer
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
}

// MARK: - Methods

extension AuthUseCase {
    
    // MARK: Sign Up
    
    private func request(requestValue: AuthUseCaseRequestValue,
                         completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        return authRepository.signUp(request: requestValue.request, completion: completion)
    }
    
    func execute(requestValue: AuthUseCaseRequestValue,
                 completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        return request(requestValue: requestValue, completion: completion)
    }
    
    // MARK: Sign In
    
    private func request(requestValue: AuthUseCaseRequestValue,
                         cached: @escaping (AuthResponseDTO?) -> Void,
                         completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        return authRepository.signIn(request: requestValue.request,
                                     cached: cached,
                                     completion: completion)
    }
    
    func execute(requestValue: AuthUseCaseRequestValue,
                 cached: @escaping (AuthResponseDTO?) -> Void,
                 completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        return request(requestValue: requestValue,
                       cached: cached,
                       completion: completion)
    }
    
    // MARK: Sign Out
    
    private func request(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
        return authRepository.signOut(completion: completion)
    }
    
    func execute(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
        return request(completion: completion)
    }
}

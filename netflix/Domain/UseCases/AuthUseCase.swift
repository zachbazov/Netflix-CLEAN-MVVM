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
    
    let authRepository: AuthRepository
    
    // MARK: Initializer
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
}

// MARK: - Methods

extension AuthUseCase {
    private func request(requestValue: AuthUseCaseRequestValue,
                         cached: @escaping (AuthResponseDTO?) -> Void,
                         completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        switch requestValue.method {
        case .signup:
            return authRepository.signUp(request: requestValue.request,
                                         cached: cached) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .signin:
            return authRepository.signIn(request: requestValue.request,
                                         cached: cached) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .signout:
            return authRepository.signOut(request: requestValue.request) { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func execute(requestValue: AuthUseCaseRequestValue,
                 cached: @escaping (AuthResponseDTO?) -> Void,
                 completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        return request(requestValue: requestValue,
                       cached: cached,
                       completion: completion)
    }
}

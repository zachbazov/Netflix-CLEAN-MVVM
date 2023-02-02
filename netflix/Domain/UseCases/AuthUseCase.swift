//
//  AuthUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - AuthUseCase Type

final class AuthUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
}

// MARK: - Methods

extension AuthUseCase {
    
    // MARK: Sign Up
    
    private func request(requestDTO: UserHTTPDTO.Request,
                         completion: @escaping (Result<UserHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return authRepository.signUp(request: requestDTO, completion: completion)
    }
    
    func execute(requestDTO: UserHTTPDTO.Request,
                 completion: @escaping (Result<UserHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return request(requestDTO: requestDTO, completion: completion)
    }
    
    // MARK: Sign In
    
    private func request(requestDTO: UserHTTPDTO.Request,
                         cached: @escaping (UserHTTPDTO.Response?) -> Void,
                         completion: @escaping (Result<UserHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return authRepository.signIn(request: requestDTO,
                                     cached: cached,
                                     completion: completion)
    }
    
    func execute(requestDTO: UserHTTPDTO.Request,
                 cached: @escaping (UserHTTPDTO.Response?) -> Void,
                 completion: @escaping (Result<UserHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return request(requestDTO: requestDTO,
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

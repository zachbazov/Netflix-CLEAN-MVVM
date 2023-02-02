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

/*
 extension AuthUseCase {
     private func request<T, U>(for response: T.Type,
                                request: U? = nil,
                                cached: ((T?) -> Void)?,
                                completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
         switch request {
         case is UserHTTPDTO.Request.Type:
             guard let request = request as? UserHTTPDTO.Request else { return nil }
             if let cached = cached as? ((UserHTTPDTO.Response?) -> Void) {
                 let completion = completion as? ((Result<UserHTTPDTO.Response, Error>) -> Void) ?? { _ in }
                 return authRepository.signIn(request: request,
                                              cached: cached,
                                              completion: completion)
             } else {
                 let completion = completion as? ((Result<UserHTTPDTO.Response, Error>) -> Void) ?? { _ in }
                 return authRepository.signUp(request: request,
                                              completion: completion)
             }
         default: return nil
         }
     }
     
     func execute<T, U>(for response: T.Type,
                        request: U? = nil,
                        cached: ((T?) -> Void)?,
                        completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
         return self.request(for: response,
                             request: request,
                             cached: cached,
                             completion: completion)
     }
     
     private func request(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
         return authRepository.signOut(completion: completion)
     }
     
     func execute(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
         return request(completion: completion)
     }
 }

 */

//
//  AuthRepository.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - AuthRepositoryEndpoints Protocol

protocol AuthRepositoryEndpoints {
    static func signUp(with authRequestDTO: AuthRequestDTO) -> Endpoint<AuthResponseDTO>
    static func signIn(with authRequestDTO: AuthRequestDTO) -> Endpoint<AuthResponseDTO>
}

// MARK: - AuthRepository Type

struct AuthRepository {
    let dataTransferService: DataTransferService
    let cache: AuthResponseStorage
}

// MARK: - Methods

extension AuthRepository {
    func signUp(request: AuthRequest,
                cached: @escaping (AuthResponseDTO?) -> Void,
                completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        
        let requestDTO = AuthRequestDTO(user: request.user.toDTO())
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.AuthRepository.signUp(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                self.cache.save(response: response, for: requestDTO)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    func signIn(request: AuthRequest,
                cached: @escaping (AuthResponseDTO?) -> Void,
                completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        
        let requestDTO = AuthRequestDTO(user: request.user.toDTO())
        let task = RepositoryTask()
        
        cache.getResponse(for: requestDTO) { result in
            if case let .success(responseDTO?) = result {
                return cached(responseDTO)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.AuthRepository.signIn(with: requestDTO)
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.cache.save(response: response, for: requestDTO)
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func signOut(request: AuthRequest, completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) -> Cancellable? {
        let requestDTO = AuthRequestDTO(user: request.user.toDTO())
        let task = RepositoryTask()
        print("signOutsignOut", request.user)
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.AuthRepository.signOut(with: requestDTO)
        task.networkTask = self.dataTransferService.request(with: endpoint, completion: { result in
            if case let .success(responseDTO) = result {
                completion(.success(responseDTO))
            }
            if case let .failure(error) = result {
                completion(.failure(error))
            }
        })
        
        return task
    }
}

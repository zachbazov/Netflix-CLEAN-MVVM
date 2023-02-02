//
//  AuthRepository.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - AuthRepositoryEndpoints Protocol

protocol AuthRepositoryEndpoints {
    static func signUp(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signIn(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signOut() -> Endpoint<Void>
}

// MARK: - AuthRepository Type

struct AuthRepository {
    let dataTransferService: DataTransferService
    let cache: AuthResponseStorage = Application.current.authResponseCache
}

// MARK: - Methods

extension AuthRepository {
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let requestDTO = UserHTTPDTO.Request(user: request.user)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.signUp(with: requestDTO)
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
    
    func signIn(request: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let requestDTO = UserHTTPDTO.Request(user: request.user)
        let task = RepositoryTask()
        
        cache.getResponse(for: requestDTO) { result in
            if case let .success(responseDTO?) = result {
                return cached(responseDTO)
            }
            
            guard !task.isCancelled else { return }
            let endpoint = APIEndpoint.signIn(with: requestDTO)
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
    
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.signOut()
        task.networkTask = self.dataTransferService.request(with: endpoint, completion: completion)
        
        return task
    }
}

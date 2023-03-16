//
//  UserRepository.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - UserRepositoryProtocol Type

private protocol UserRepositoryInput {
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signIn(request: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable?
    
    func signUp(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signOut(request: UserHTTPDTO.Request) async -> VoidHTTP.Response?
    
    func getUserProfiles(request: UserProfileHTTPDTO.Request,
                         completion: @escaping (Result<UserProfileHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    
    func getUserProfiles(request: UserProfileHTTPDTO.Request) async -> UserProfileHTTPDTO.Response?
}

private typealias UserRepositoryProtocol = UserRepositoryInput

// MARK: - UserRepository Type

final class UserRepository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    let responseStorage: AuthResponseStorage = Application.app.stores.authResponses
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - Repository Implementation

extension UserRepository: Repository {}

// MARK: - UserRepositoryProtocol Implementation

extension UserRepository: UserRepositoryProtocol {
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.signUp(with: request)
        task.networkTask = dataTransferService.request(with: endpoint) { [weak self] result in
            switch result {
            case .success(let response):
                self?.responseStorage.save(response: response, for: request)
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
        let task = RepositoryTask()
        
        responseStorage.getResponse(for: request) { result in
            if case let .success(response?) = result {
                return cached(response)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.signIn(with: request)
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.responseStorage.save(response: response, for: request)
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
        
        
        let authService = Application.app.services.authentication
        let request = UserHTTPDTO.Request(user: authService.user!)
        guard let endpoint = APIEndpoint.signOut(with: request) else { return nil }
        task.networkTask = dataTransferService.request(with: endpoint, completion: completion)
        
        let context = responseStorage.coreDataStorage.context()
        responseStorage.deleteResponse(for: request, in: context)
        
        return task
    }
    
    func getUserProfiles(request: UserProfileHTTPDTO.Request,
                         completion: @escaping (Result<UserProfileHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getMyUserProfiles(with: request)
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    func signUp(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        let endpoint = APIEndpoint.signUp(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            responseStorage.save(response: response, for: request)
            return response
        }
        
        return nil
    }
    
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        guard let cached = await responseStorage.getResponse(for: request) else {
            let endpoint = APIEndpoint.signIn(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                responseStorage.save(response: response, for: request)
                return response
            }
            
            return nil
        }
        
        return cached
    }
    
    func signOut(request: UserHTTPDTO.Request) async -> VoidHTTP.Response? {
        guard let endpoint = APIEndpoint.signOut(with: request) else { return nil }
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response
        }
        
        return nil
    }
    
    func getUserProfiles(request: UserProfileHTTPDTO.Request) async -> UserProfileHTTPDTO.Response? {
        let endpoint = APIEndpoint.getMyUserProfiles(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response
        }
        
        return nil
    }
}

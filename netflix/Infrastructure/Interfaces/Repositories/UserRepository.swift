//
//  UserRepository.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - UserRepositoryRouting Type

protocol UserRepositoryRouting {
    static func signUp(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signIn(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signOut(with request: UserHTTPDTO.Request) -> Endpoint<VoidHTTPDTO.Response>?
}

// MARK: - UserRepositoryProtocol Type

private protocol UserRepositoryProtocol {
    var dataTransferService: DataTransferService { get }
    var userResponses: UserHTTPResponseStore { get }
    var task: Cancellable? { get }
    
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signIn(request: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signOut(completion: @escaping (Result<VoidHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    
    func getUserProfiles(request: UserProfileHTTPDTO.GET.Request,
                         completion: @escaping (Result<UserProfileHTTPDTO.GET.Response, DataTransferError>) -> Void) -> Cancellable?
    func createUserProfile(request: UserProfileHTTPDTO.POST.Request,
                           completion: @escaping (Result<UserProfileHTTPDTO.POST.Response, DataTransferError>) -> Void) -> Cancellable?
    func updateUserProfile(request: UserHTTPDTO.Request,
                           completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    
    func signUp(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signOut(request: UserHTTPDTO.Request) async -> VoidHTTPDTO.Response?
    
    func getUserProfiles(request: UserProfileHTTPDTO.GET.Request) async -> UserProfileHTTPDTO.GET.Response?
    func createUserProfile(request: UserProfileHTTPDTO.POST.Request) async -> UserProfileHTTPDTO.POST.Response?
    func updateUserData(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
}

// MARK: - UserRepository Type

final class UserRepository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    let userResponses: UserHTTPResponseStore = Application.app.stores.userResponses
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
                self?.userResponses.save(response: response, for: request)
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
        
        userResponses.getResponse(for: request) { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(response?) = result {
                return cached(response)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.signIn(with: request)
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.userResponses.save(response: response, for: request)
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func signOut(completion: @escaping (Result<VoidHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let authService = Application.app.services.authentication
        let request = UserHTTPDTO.Request(user: authService.user!, selectedProfile: nil)
        guard let endpoint = APIEndpoint.signOut(with: request) else { return nil }
        task.networkTask = dataTransferService.request(with: endpoint, completion: completion)
        
        let context = userResponses.coreDataStorage.context()
        userResponses.deleteResponse(for: request, in: context)
        
        return task
    }
    
    func getUserProfiles(request: UserProfileHTTPDTO.GET.Request,
                         completion: @escaping (Result<UserProfileHTTPDTO.GET.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getUserProfiles(with: request)
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
    
    func createUserProfile(request: UserProfileHTTPDTO.POST.Request,
                           completion: @escaping (Result<UserProfileHTTPDTO.POST.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.createUserProfile(with: request)
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
    
    func updateUserProfile(request: UserHTTPDTO.Request,
                           completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.updateUserData(with: request)
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
    
    func getUserProfiles(request: UserProfileHTTPDTO.GET.Request) async -> UserProfileHTTPDTO.GET.Response? {
        let endpoint = APIEndpoint.getUserProfiles(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response
        }
        
        return nil
    }
    
    func signUp(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        let endpoint = APIEndpoint.signUp(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            userResponses.save(response: response, for: request)
            return response
        }
        
        return nil
    }
    
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        guard let cached = await userResponses.getResponse(for: request) else {
            let endpoint = APIEndpoint.signIn(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                userResponses.save(response: response, for: request)
                return response
            }
            
            return nil
        }
        
        return cached
    }
    
    func signOut(request: UserHTTPDTO.Request) async -> VoidHTTPDTO.Response? {
        guard let endpoint = APIEndpoint.signOut(with: request) else { return nil }
        let result = await dataTransferService.request(with: endpoint)
        let context = userResponses.coreDataStorage.context()

        if case let .success(response) = result {
            userResponses.deleteResponse(for: request, in: context)
            return response
        }
        
        return nil
    }
    
    func createUserProfile(request: UserProfileHTTPDTO.POST.Request) async -> UserProfileHTTPDTO.POST.Response? {
        let endpoint = APIEndpoint.createUserProfile(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response
        }
        
        return nil
    }
    
    func updateUserData(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        let authService = Application.app.services.authentication
        let endpoint = APIEndpoint.updateUserData(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            var response = response
            response.token = authService.userToken
            userResponses.save(response: response, for: request)
            return response
        }
        
        return nil
    }
}

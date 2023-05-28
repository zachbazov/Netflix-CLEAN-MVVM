//
//  UserRepository.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - UserRepositoryEndpointing Type

protocol UserRepositoryEndpointing {
    static func signUp(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signIn(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signOut(with request: UserHTTPDTO.Request) -> Endpoint<VoidHTTPDTO.Response>?
}

// MARK: - UserAuthenticating Type

protocol UserAuthenticating {
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signIn(request: UserHTTPDTO.Request,
                cached: @escaping (UserHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    func signOut(completion: @escaping (Result<VoidHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable?
    
    func signUp(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signOut(request: UserHTTPDTO.Request) async -> VoidHTTPDTO.Response?
}

// MARK: - UserRepository Type

final class UserRepository: Repository {
    let authenticator: UserAuthenticating
    let persistentStore: UserHTTPResponseStore
    let invoker: RequestInvoking
    
    init(dataTransferService: DataTransferService,
         authenticator: UserAuthenticating,
         persistentStore: UserHTTPResponseStore,
         invoker: RequestInvoking) {
        self.authenticator = authenticator
        self.persistentStore = persistentStore
        self.invoker = invoker
        super.init(dataTransferService: dataTransferService)
    }
}

// MARK: - UserAuthenticating Implementation

final class UserRepositoryAuthenticator: UserAuthenticating {
    let dataTransferService: DataTransferService
    let persistentStore: UserHTTPResponseStore
    
    init(dataTransferService: DataTransferService, persistentStore: UserHTTPResponseStore) {
        self.dataTransferService = dataTransferService
        self.persistentStore = persistentStore
    }
    
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.signUp(with: request)
        
        task.networkTask = dataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.persistentStore.save(response: response, for: request)
                
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
        
        persistentStore.getResponse(for: request) { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(response?) = result {
                return cached(response)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.signIn(with: request)
            
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.persistentStore.save(response: response, for: request)
                    
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
        
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return nil }
        
        let request = UserHTTPDTO.Request(user: user, selectedProfile: nil)
        
        guard let endpoint = APIEndpoint.signOut(with: request) else { return nil }
        task.networkTask = dataTransferService.request(with: endpoint, completion: completion)
        
        let context = persistentStore.coreDataStorage.context()
        persistentStore.deleteResponse(for: request, in: context)
        
        return task
    }
    
    func signUp(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        let endpoint = APIEndpoint.signUp(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            persistentStore.save(response: response, for: request)
            return response
        }
        
        return nil
    }
    
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        guard let cached = await persistentStore.getResponse(for: request) else {
            let endpoint = APIEndpoint.signIn(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                persistentStore.save(response: response, for: request)
                
                return response
            }
            
            return nil
        }
        
        return cached
    }
    
    func signOut(request: UserHTTPDTO.Request) async -> VoidHTTPDTO.Response? {
        guard let endpoint = APIEndpoint.signOut(with: request) else { return nil }
        
        let result = await dataTransferService.request(with: endpoint)
        let context = persistentStore.coreDataStorage.context()

        if case let .success(response) = result {
            persistentStore.deleteResponse(for: request, in: context)
            
            return response
        }
        
        return nil
    }
}

// MARK: - RepositoryInvoker Type

final class RepositoryInvoker {
    let dataTransferService: DataTransferService
    let persistentStore: UserHTTPResponseStore
    
    init(dataTransferService: DataTransferService, persistentStore: UserHTTPResponseStore) {
        self.dataTransferService = dataTransferService
        self.persistentStore = persistentStore
    }
}

// MARK: - RequestInvoking Implementation

extension RepositoryInvoker: RequestInvoking {
    func getAll<T, U>(request: U, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        switch request {
        case let request as ProfileHTTPDTO.GET.Request:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = APIEndpoint.getUserProfiles(with: request)
            task.networkTask = dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            return task
        default:
            return nil
        }
    }
    
    func createOne<T, U>(request: U, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        switch request {
        case let request as ProfileHTTPDTO.POST.Request:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = APIEndpoint.createUserProfile(with: request)
            task.networkTask = dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            return task
        default:
            return nil
        }
    }
    
    func updateOne<T, U>(request: U, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        switch request {
        case let request as UserHTTPDTO.Request:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = APIEndpoint.updateUserData(with: request)
            task.networkTask = dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            return task
        default:
            return nil
        }
    }
    
    func getAll<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        switch request {
        case let request as ProfileHTTPDTO.GET.Request:
            let endpoint = APIEndpoint.getUserProfiles(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                return response as? T
            }
            
            return nil
        default:
            return nil
        }
    }
    
    func createOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        switch request {
        case let request as ProfileHTTPDTO.POST.Request:
            let endpoint = APIEndpoint.createUserProfile(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                return response as? T
            }
            
            return nil
        default:
            return nil
        }
    }
    
    func updateOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        switch request {
        case let request as UserHTTPDTO.Request:
            let authService = Application.app.services.auth
            let endpoint = APIEndpoint.updateUserData(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                var response = response
                response.token = authService.userToken
                
                persistentStore.save(response: response, for: request)
                
                return response as? T
            }
            
            return nil
        default:
            return nil
        }
    }
}

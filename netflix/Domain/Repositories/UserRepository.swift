//
//  UserRepository.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - UserRepositoryURLReferrable Type

protocol UserRepositoryURLReferrable {
    static func signUp(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signIn(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signOut(with request: UserHTTPDTO.Request) -> Endpoint<VoidHTTPDTO.Response>
    
    static func getUserProfiles(with request: ProfileHTTPDTO.GET.Request) -> Endpoint<ProfileHTTPDTO.GET.Response>
    static func createUserProfile(with request: ProfileHTTPDTO.POST.Request) -> Endpoint<ProfileHTTPDTO.POST.Response>
    static func updateUserData(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
}

// MARK: - UserAuthenticable Type

protocol UserAuthenticable {
    func sign<T>(endpoint: UserUseCase.Endpoints,
                 request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable?
}

// MARK: - UserRepository Type

final class UserRepository: Repository {
    let dataTransferService: DataServiceTransferring
    let persistentStore: UserHTTPResponseStore
    
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    init(dataTransferService: DataTransferService, persistentStore: UserHTTPResponseStore) {
        self.dataTransferService = dataTransferService
        self.persistentStore = persistentStore
    }
}

// MARK: - UserRepositoryURLReferrable Implementation

extension UserRepository: UserRepositoryURLReferrable {
    static func signUp(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response> {
        let path = "api/v1/users/signup"
        let method: HTTPMethodType = .post
        let headerParams = ["content-type": "application/json"]
        let bodyParams: [String: Any] = ["name": request.user.name ?? "Undefined",
                                         "email": request.user.email!,
                                         "password": request.user.password!,
                                         "passwordConfirm": request.user.passwordConfirm!]
        
        return Endpoint(path: path, method: method, headerParameters: headerParams, bodyParameters: bodyParams)
    }
    
    static func signIn(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response> {
        let path = "api/v1/users/signin"
        let method: HTTPMethodType = .post
        let headerParams = ["content-type": "application/json"]
        let bodyParams: [String: Any] = ["email": request.user.email!,
                                         "password": request.user.password!]
        
        return Endpoint(path: path, method: method, headerParameters: headerParams, bodyParameters: bodyParams)
    }
    
    static func signOut(with request: UserHTTPDTO.Request) -> Endpoint<VoidHTTPDTO.Response> {
        let path = "api/v1/users/signout"
        let method: HTTPMethodType = .get
        let headerParams = ["content-type": "application/json"]
        
        let authService = Application.app.services.auth
        
        guard authService.user?._id == request.user._id else { fatalError() }
        
        return Endpoint(path: path, method: method, headerParameters: headerParams)
    }
    
    static func getUserProfiles(with request: ProfileHTTPDTO.GET.Request) -> Endpoint<ProfileHTTPDTO.GET.Response> {
        let path = "api/v1/users/profiles"
        let method: HTTPMethodType = .get
        let headerParams = ["content-type": "application/json"]
        let queryParams: [String: Any] = ["user": request.user._id ?? ""]
        
        return Endpoint(path: path, method: method, headerParameters: headerParams, queryParameters: queryParams)
    }
    
    static func createUserProfile(with request: ProfileHTTPDTO.POST.Request) -> Endpoint<ProfileHTTPDTO.POST.Response> {
        let path = "api/v1/users/profiles"
        let method: HTTPMethodType = .post
        let headerParams = ["content-type": "application/json"]
        let queryParams: [String: Any] = ["user": request.user._id ?? ""]
        let bodyParams: [String: Any] = ["name": request.profile.name]
        
        return Endpoint(path: path, method: method, headerParameters: headerParams, queryParameters: queryParams, bodyParameters: bodyParams)
    }
    
    static func updateUserData(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response> {
        let path = "api/v1/users/update-data"
        let method: HTTPMethodType = .patch
        let headerParams = ["content-type": "application/json"]
        let queryParams: [String: Any] = ["email": request.user.email ?? ""]
        let bodyParams: [String: Any] = ["name": request.user.name ?? "",
                                         "selectedProfile": request.selectedProfile as Any]
        
        return Endpoint(path: path, method: method, headerParameters: headerParams, queryParameters: queryParams, bodyParameters: bodyParams)
    }
}

// MARK: - UserAuthenticable Implementation

extension UserRepository: UserAuthenticable {
    func sign<T>(endpoint: UserUseCase.Endpoints,
                 request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? {
        switch endpoint {
        case .signIn:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            
            let task = RepositoryTask()
            
            persistentStore.getResponse(for: request) { [weak self] result in
                guard let self = self else { return }
                
                if case let .success(response?) = result {
                    return cached(response as? T)
                }
                
                guard !task.isCancelled else { return }
                
                let endpoint = UserRepository.signIn(with: request)
                
                task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                    switch result {
                    case .success(let response):
                        self.persistentStore.save(response: response, for: request)
                        
                        completion(.success(response as! T))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
            
            return task
        case .signUp:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = UserRepository.signUp(with: request)
            
            task.networkTask = dataTransferService.request(with: endpoint) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.persistentStore.save(response: response, for: request)
                    
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            return task
        case .signOut:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let authService = Application.app.services.auth
            
            guard let user = authService.user else { return nil }
            
            let request = UserHTTPDTO.Request(user: user, selectedProfile: nil)
            
            let endpoint = UserRepository.signOut(with: request)
            
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
}

// MARK: - RepositoryRequestable Implementation

extension UserRepository: RepositoryRequestable {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch request {
        case let request as ProfileHTTPDTO.GET.Request:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = UserRepository.getUserProfiles(with: request)
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
    
    func create<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch request {
        case let request as ProfileHTTPDTO.POST.Request:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = UserRepository.createUserProfile(with: request)
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
    
    func update<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch request {
        case let request as UserHTTPDTO.Request:
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = UserRepository.updateUserData(with: request)
            
            task.networkTask = dataTransferService.request(with: endpoint) { [weak self] result in
                switch result {
                case .success(let response):
                    completion(.success(response as! T))
                    
                    self?.persistentStore.getResponse(for: request) { (result) in
                        switch result {
                        case .success(let resp):
                            guard let resp = resp else { return }
                            resp.data?.selectedProfile = response.data?.selectedProfile

                            self?.persistentStore.save(response: resp, for: request)
                        case .failure(let error):
                            printIfDebug(.error, "\(error)")
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            return task
        default:
            return nil
        }
    }
}

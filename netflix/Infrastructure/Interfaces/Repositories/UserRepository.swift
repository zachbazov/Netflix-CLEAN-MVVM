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
}

private typealias UserRepositoryProtocol = UserRepositoryInput

// MARK: - UserRepository Type

final class UserRepository: Repository {
    func getAll<T>(cached: @escaping (T?) -> Void, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func getOne<T, U>(request: U, cached: @escaping (T?) -> Void, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
    
    func getAll<T>() async -> T? where T: Decodable {
        return nil
    }
    
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    let responseStorage: AuthResponseStorage = Application.app.stores.authResponses
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - UserRepositoryProtocol Implementation

extension UserRepository: UserRepositoryProtocol {
    func signUp(request: UserHTTPDTO.Request,
                completion: @escaping (Result<UserHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let requestDTO = UserHTTPDTO.Request(user: request.user)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.signUp(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint) { [weak self] result in
            switch result {
            case .success(let response):
                self?.responseStorage.save(response: response, for: requestDTO)
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
        
        responseStorage.getResponse(for: requestDTO) { result in
            if case let .success(responseDTO?) = result {
                return cached(responseDTO)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.signIn(with: requestDTO)
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.responseStorage.save(response: response, for: requestDTO)
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func signIn(request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        guard let cached = await responseStorage.getResponse(for: request) else {
            let endpoint = APIEndpoint.signIn(with: request)
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                responseStorage.save(response: response, for: request)
                print("new")
                return response
            }
            
            return nil
        }
        print("cached")
        return cached
    }
    
    func signOut(completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.signOut()
        task.networkTask = dataTransferService.request(with: endpoint, completion: completion)
        
        let authService = Application.app.services.authentication
        let request = UserHTTPDTO.Request(user: authService.user!)
        let context = responseStorage.coreDataStorage.context()
        responseStorage.deleteResponse(for: request, in: context)
        print("delete", request.user.toDomain())
        return task
    }
}

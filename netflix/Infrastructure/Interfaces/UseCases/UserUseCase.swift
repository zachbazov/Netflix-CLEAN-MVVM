//
//  UserUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - UserUseCase Type

final class UserUseCase {
    let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
}

// MARK: - Endpoints Type

extension UserUseCase {
    enum Endpoints {
        case signIn
        case signUp
        case signOut
        case updateUserData
        case getUserProfiles
        case createUserProfile
    }
}

// MARK: - UseCase Implementation

extension UserUseCase: UseCase {
    func request<T>(endpoint: Endpoints,
                    for response: T.Type,
                    request: Any?,
                    cached: @escaping (T?) -> Void,
                    completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch endpoint {
        case .signUp:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.signUp(request: request, completion: completion)
        case .signIn:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            let cached = cached as? ((UserHTTPDTO.Response?) -> Void) ?? { _ in }
            return repository.signIn(request: request, cached: cached, completion: completion)
        case .signOut:
            let completion = completion as? ((Result<VoidHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.signOut(completion: completion)
        case .updateUserData:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.update(request: request, completion: completion)
        case .getUserProfiles:
            return repository.find(request: request, cached: cached, completion: completion)
        case .createUserProfile:
            guard let request = request as? ProfileHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<ProfileHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.create(request: request, completion: completion)
        }
    }
    
    func request<T>(endpoint: Endpoints, for response: T.Type, request: Any?) async -> T? where T: Decodable {
        switch endpoint {
        case .signUp:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            
            return await repository.signUp(request: request) as? T
        case .signIn:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            
            return await repository.signIn(request: request) as? T
        case .signOut:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            
            return await repository.signOut(request: request) as? T
        case .updateUserData:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            
            return await repository.update(request: request)
        case .getUserProfiles:
            return await repository.find(request: request)
        case .createUserProfile:
            guard let request = request as? ProfileHTTPDTO.POST.Request else { return nil }
            
            return await repository.create(request: request)
        }
    }
}

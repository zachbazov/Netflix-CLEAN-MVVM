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
        
        case getUserProfiles
        case createUserProfile
        case updateUserProfile
        case updateUserProfileSettings
        
        case updateUserData
        
        case deleteUserProfile
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
            return repository.sign(endpoint: endpoint, request: request, cached: cached, completion: completion)
        case .signIn:
            return repository.sign(endpoint: endpoint, request: request, cached: cached, completion: completion)
        case .signOut:
            return repository.sign(endpoint: endpoint, request: request, cached: cached, completion: completion)
        case .getUserProfiles:
            return repository.find(request: request, cached: cached, completion: completion)
        case .createUserProfile:
            return repository.create(request: request, completion: completion)
        case .updateUserProfile:
            return repository.update(request: request, completion: completion)
        case .updateUserProfileSettings:
            return repository.update(request: request, completion: completion)
        case .updateUserData:
            return repository.update(request: request, completion: completion)
        case .deleteUserProfile:
            return repository.delete(request: request, completion: completion)
        }
    }
    
    func request(endpoint: Endpoints,
                 request: Any?,
                 completion: @escaping (Result<Void, DataTransferError>) -> Void) -> Cancellable? {
        switch endpoint {
        case .deleteUserProfile:
            return repository.delete(request: request, completion: completion)
        default: return nil
        }
    }
}

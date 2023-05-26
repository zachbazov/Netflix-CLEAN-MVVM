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

// MARK: - UseCase Implementation

extension UserUseCase: UseCase {
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? {
        switch endpoint {
        case .signUp:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.authenticator.signUp(request: request, completion: completion)
        case .signIn:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            let cached = cached as? ((UserHTTPDTO.Response?) -> Void) ?? { _ in }
            return repository.authenticator.signIn(request: request, cached: cached, completion: completion)
        case .signOut:
            let completion = completion as? ((Result<VoidHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.authenticator.signOut(completion: completion)
        case .updateUserData:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.invoker.updateOne(request: request, completion: completion)
        case .getUserProfiles:
            guard let request = request as? UserProfileHTTPDTO.GET.Request else { return nil }
            let completion = completion as? ((Result<UserProfileHTTPDTO.GET.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.invoker.getAll(request: request, completion: completion)
        case .createUserProfile:
            guard let request = request as? UserProfileHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<UserProfileHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.invoker.createOne(request: request, completion: completion)
        }
    }
    
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U) async -> T? where T: Decodable {
        switch endpoint {
        case .signUp:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            return await repository.authenticator.signUp(request: request) as? T
        case .signIn:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            return await repository.authenticator.signIn(request: request) as? T
        case .signOut:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            return await repository.authenticator.signOut(request: request) as? T
        case .updateUserData:
            guard let request = request as? UserHTTPDTO.Request else { return nil }
            return await repository.invoker.updateOne(request: request)
        case .getUserProfiles:
            guard let request = request as? UserProfileHTTPDTO.GET.Request else { return nil }
            return await repository.invoker.getAll(request: request)
        case .createUserProfile:
            guard let request = request as? UserProfileHTTPDTO.POST.Request else { return nil }
            return await repository.invoker.createOne(request: request)
        }
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

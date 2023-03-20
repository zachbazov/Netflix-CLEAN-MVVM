//
//  UserUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - UserUseCase Type

final class UserUseCase {
    typealias T = UserRepository
    let repository: T = UserRepository()
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
            guard let request = request as? UserHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.signUp(request: request, completion: completion)
        case .signIn:
            guard let request = request as? UserHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            let cached = cached as? ((UserHTTPDTO.POST.Response?) -> Void) ?? { _ in }
            return repository.signIn(request: request, cached: cached, completion: completion)
        case .signOut:
            let completion = completion as? ((Result<VoidHTTP.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.signOut(completion: completion)
        case .updateUserData:
            guard let request = request as? UserHTTPDTO.PATCH.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.PATCH.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.updateUserProfile(request: request, completion: completion)
        case .getUserProfiles:
            guard let request = request as? UserProfileHTTPDTO.GET.Request else { return nil }
            let completion = completion as? ((Result<UserProfileHTTPDTO.GET.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.getUserProfiles(request: request, completion: completion)
        case .createUserProfile:
            guard let request = request as? UserProfileHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<UserProfileHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.createUserProfile(request: request, completion: completion)
        }
    }
    
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U) async -> T? where T: Decodable {
        switch endpoint {
        case .signUp:
            guard let request = request as? UserHTTPDTO.POST.Request else { return nil }
            return await repository.signUp(request: request) as? T
        case .signIn:
            guard let request = request as? UserHTTPDTO.POST.Request else { return nil }
            return await repository.signIn(request: request) as? T
        case .signOut:
            guard let request = request as? UserHTTPDTO.GET.Request else { return nil }
            return await repository.signOut(request: request) as? T
        case .updateUserData:
            guard let request = request as? UserHTTPDTO.PATCH.Request else { return nil }
            return await repository.updateUserData(request: request) as? T
        case .getUserProfiles:
            guard let request = request as? UserProfileHTTPDTO.GET.Request else { return nil }
            return await repository.getUserProfiles(request: request) as? T
        case .createUserProfile:
            guard let request = request as? UserProfileHTTPDTO.POST.Request else { return nil }
            return await repository.createUserProfile(request: request) as? T
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

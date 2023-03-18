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
    let repository = UserRepository()
}

// MARK: - UseCase Implementation

extension UserUseCase: UseCase {
    /// Send a task operation according to the parameters.
    /// In case data exists, exit the scope and execute the cached operation.
    /// In case data doesn't exist, exit the scope and execute the completion handler.
    /// - Parameters:
    ///   - response: Expected response type.
    ///   - request: Expected request type.
    ///   - cached: Cached operation, if exists.
    ///   - completion: Completion handler.
    /// - Returns: A task operation.
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? {
        switch response {
        case is UserHTTPDTO.POST.Response.Type:
            guard let request = request as? UserHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            // In case there is data in the storage, perform a sign-in task.
            if let cached = cached as? ((UserHTTPDTO.POST.Response?) -> Void) {
                return repository.signIn(request: request, cached: cached, completion: completion)
            }
            // In case there isn't, perform a sign-up task.
            return repository.signUp(request: request, completion: completion)
        case is VoidHTTP.Response.Type:
            // Perform a sign-out task.
            let completion = completion as? ((Result<VoidHTTP.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.signOut(completion: completion)
        case is UserHTTPDTO.PATCH.Response.Type:
            guard let request = request as? UserHTTPDTO.PATCH.Request else { return nil }
            let completion = completion as? ((Result<UserHTTPDTO.PATCH.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.updateUserProfile(request: request, completion: completion)
        case is UserProfileHTTPDTO.GET.Response.Type:
            guard let request = request as? UserProfileHTTPDTO.GET.Request else { return nil }
            let completion = completion as? ((Result<UserProfileHTTPDTO.GET.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.getUserProfiles(request: request, completion: completion)
        case is UserProfileHTTPDTO.POST.Response.Type:
            guard let request = request as? UserProfileHTTPDTO.POST.Request else { return nil }
            let completion = completion as? ((Result<UserProfileHTTPDTO.POST.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.createUserProfile(request: request, completion: completion)
        default: return nil
        }
    }
    
    func request<T, U>(for response: T.Type, request: U) async -> T? where T: Decodable {
        switch response {
        case is UserHTTPDTO.POST.Response.Type:
            guard let request = request as? UserHTTPDTO.POST.Request else { return nil }
            guard request.user.passwordConfirm != nil else {
                return await repository.signIn(request: request) as? T
            }
            return await repository.signUp(request: request) as? T
        case is VoidHTTP.Response.Type:
            guard let request = request as? UserHTTPDTO.GET.Request else { return nil }
            return await repository.signOut(request: request) as? T
        case is UserHTTPDTO.PATCH.Response.Type:
            guard let request = request as? UserHTTPDTO.PATCH.Request else { return nil }
            return await repository.updateUserData(request: request) as? T
        case is UserProfileHTTPDTO.GET.Response.Type:
            guard let request = request as? UserProfileHTTPDTO.GET.Request else { return nil }
            return await repository.getUserProfiles(request: request) as? T
        case is UserProfileHTTPDTO.POST.Response.Type:
            guard let request = request as? UserProfileHTTPDTO.POST.Request else { return nil }
            return await repository.createUserProfile(request: request) as? T
        default: return nil
        }
    }
}

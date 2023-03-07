//
//  MediaUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - MediaUseCase Type

final class MediaUseCase: UseCase {
    typealias T = MediaRepository
    let repository = MediaRepository()
}

// MARK: - RouteRequestable Implementation

extension MediaUseCase: RequestableRoute {
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is MediaHTTPDTO.Response.Type:
            switch request {
            case is Any.Type:
                let cached = cached as? ((MediaHTTPDTO.Response?) -> Void) ?? { _ in }
                let completion = completion as? ((Result<MediaHTTPDTO.Response, Error>) -> Void) ?? { _ in }
                return repository.getAll(cached: cached, completion: completion)
            case is [String: Any]:
                let completion = completion as? ((Result<MediaHTTPDTO.Response, Error>) -> Void) ?? { _ in }
                return repository.getTopSearches(completion: completion)
            default: return nil
            }
        case is [Media].Type:
            guard let request = request as? SearchHTTPDTO.Request else { return nil }
            let cached = cached as? (([Media]?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<[Media], Error>) -> Void) ?? { _ in }
            return repository.search(requestDTO: request, cached: cached, completion: completion)
        case is NewsHTTPDTO.Response.Type:
            let completion = completion as? ((Result<NewsHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getUpcomings(completion: completion)
        default: return nil
        }
    }
    
    func request<T, U>(for response: T.Type, request: U.Type) async throws -> T? {
        switch response {
        case is MediaHTTPDTO.Response.Type:
            switch request {
            case is MediaHTTPDTO.Request.Type:
                return try await repository.getTopSeaches() as? T
            default:
                return try await repository.getAll() as? T
            }
        default: return nil
        }
    }
}

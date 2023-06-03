//
//  MediaUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - MediaUseCase Type

final class MediaUseCase {
    let repository: MediaRepository
    
    init(repository: MediaRepository) {
        self.repository = repository
    }
}

// MARK: - Endpoints Type

extension MediaUseCase {
    enum Endpoints {
        case getAllMedia
        case getTopSearches
        case getUpcomings
        case searchMedia
    }
}

// MARK: - UseCase Implementation

extension MediaUseCase: UseCase {
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch endpoint {
        case .getAllMedia:
            let cached = cached as? ((MediaHTTPDTO.Response?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<MediaHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getAll(cached: cached, completion: completion)
        case .getTopSearches:
            let completion = completion as? ((Result<SearchHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getTopSearches(completion: completion)
        case .getUpcomings:
            let completion = completion as? ((Result<NewsHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getUpcomings(completion: completion)
        case .searchMedia:
            guard let request = request as? SearchHTTPDTO.Request else { return nil }
            let cached = cached as? ((SearchHTTPDTO.Response?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<SearchHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.search(requestDTO: request, cached: cached, completion: completion)
        }
    }
    
    func request<T>(endpoint: Endpoints, for response: T.Type) async -> T? where T: Decodable {
        switch endpoint {
        case .getAllMedia:
            return await repository.getAll()
        case .getTopSearches:
            return await repository.getTopSearches() as? T
        case .getUpcomings:
            return await repository.getUpcomings() as? T
        default: return nil
        }
    }
    
    func request<T, U>(endpoint: Endpoints, for response: T.Type, request: U) async -> T? where T: Decodable {
        switch endpoint {
        case .searchMedia:
            guard let request = request as? SearchHTTPDTO.Request else { return nil }
            return await repository.search(requestDTO: request) as? T
        default: return nil
        }
    }
}

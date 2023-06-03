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
    func request<T>(endpoint: Endpoints,
                    for response: T.Type,
                    request: Any?,
                    cached: @escaping (T?) -> Void,
                    completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch endpoint {
        case .getAllMedia:
            let cached = cached as? ((MediaHTTPDTO.Response?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<MediaHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.find(request: request, cached: cached, completion: completion)
        case .getTopSearches:
            let completion = completion as? ((Result<SearchHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.getTopSearches(completion: completion)
        case .getUpcomings:
            let completion = completion as? ((Result<NewsHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.getUpcomings(completion: completion)
        case .searchMedia:
            guard let request = request as? SearchHTTPDTO.Request else { return nil }
            let cached = cached as? ((SearchHTTPDTO.Response?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<SearchHTTPDTO.Response, DataTransferError>) -> Void) ?? { _ in }
            return repository.search(requestDTO: request, cached: cached, completion: completion)
        }
    }
    
    func request<T>(endpoint: Endpoints, for response: T.Type, request: Any?) async -> T? where T: Decodable {
        switch endpoint {
        case .getAllMedia:
            return await repository.find(request: request)
        case .getTopSearches:
            return await repository.getTopSearches() as? T
        case .getUpcomings:
            return await repository.getUpcomings() as? T
        case .searchMedia:
            guard let request = request as? SearchHTTPDTO.Request else { return nil }
            
            return await repository.search(requestDTO: request) as? T
        }
    }
}

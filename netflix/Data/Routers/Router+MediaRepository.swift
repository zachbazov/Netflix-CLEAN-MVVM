//
//  Router+MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

extension Router<MediaRepository> {
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is MediaHTTPDTO.Response.Type:
            guard let repository = repository as MediaRepository? else { return nil }
            let cached = cached as? ((MediaHTTPDTO.Response?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<MediaHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getAll(cached: cached, completion: completion)
        case is [Media].Type:
            guard let repository = repository as MediaRepository? else { return nil }
            guard let request = request as? SearchHTTPDTO.Request else { return nil }
            let cached = cached as? (([Media]?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<[Media], Error>) -> Void) ?? { _ in }
            return repository.search(requestDTO: request, cached: cached, completion: completion)
        case is NewsHTTPDTO.Response.Type:
            guard let repository = repository as MediaRepository? else { return nil }
            let completion = completion as? ((Result<NewsHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getUpcomings(completion: completion)
        default: return nil
        }
    }
}

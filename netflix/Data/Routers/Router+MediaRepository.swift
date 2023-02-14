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
        default: return nil
        }
    }
}

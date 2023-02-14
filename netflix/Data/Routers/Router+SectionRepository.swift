//
//  Router+SectionRepository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

extension Router<SectionRepository> {
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is SectionHTTPDTO.Response.Type:
            guard let repository = repository as SectionRepository? else { return nil }
            let completion = completion as? ((Result<SectionHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getAll(completion: completion)
        default: return nil
        }
    }
}

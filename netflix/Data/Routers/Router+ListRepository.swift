//
//  Router+ListRepository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

extension Router<ListRepository> {
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is ListHTTPDTO.GET.Response.Type:
            guard let repository = repository as ListRepository? else { return nil }
            guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
            let completion = completion as? ((Result<ListHTTPDTO.GET.Response, Error>) -> Void) ?? { _ in }
            return repository.getOne(request: request, completion: completion)
        case is ListHTTPDTO.PATCH.Response.Type:
            guard let repository = repository as ListRepository? else { return nil }
            guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
            let completion = completion as? ((Result<ListHTTPDTO.PATCH.Response, Error>) -> Void) ?? { _ in }
            return repository.updateOne(request: request, completion: completion)
        default: return nil
        }
    }
}

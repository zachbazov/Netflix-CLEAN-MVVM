//
//  SeasonUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - SeasonUseCase Type

final class SeasonUseCase: UseCase {
    typealias T = SeasonRepository
    let repository = SeasonRepository()
}

// MARK: - RouteRequestable Implementation

extension SeasonUseCase: RouteRequestable {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        guard let request = request as? SeasonHTTPDTO.Request else { return nil }
        let completion = completion as? ((Result<SeasonHTTPDTO.Response, Error>) -> Void) ?? { _ in }
        return repository.getSeason(request: request, completion: completion)
    }
}

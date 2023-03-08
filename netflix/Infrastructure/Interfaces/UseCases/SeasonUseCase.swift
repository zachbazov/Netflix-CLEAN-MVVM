//
//  SeasonUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - SeasonUseCase Type

final class SeasonUseCase {
    typealias T = SeasonRepository
    let repository = SeasonRepository()
}

// MARK: - UseCase Implementation

extension SeasonUseCase: UseCase {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        guard let request = request as? SeasonHTTPDTO.Request else { return nil }
        let completion = completion as? ((Result<SeasonHTTPDTO.Response, Error>) -> Void) ?? { _ in }
        return repository.getOne(request: request, cached: { _ in }, completion: completion)
    }
}

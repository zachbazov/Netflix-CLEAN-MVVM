//
//  SectionUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - SectionUseCase Type

final class SectionUseCase: UseCase {
    typealias T = SectionRepository
    let repository = SectionRepository()
}

// MARK: - RouteRequestable Implementation

extension SectionUseCase: RequestableRoute {
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        let completion = completion as? ((Result<SectionHTTPDTO.Response, Error>) -> Void) ?? { _ in }
        return repository.getAll(completion: completion)
    }
}

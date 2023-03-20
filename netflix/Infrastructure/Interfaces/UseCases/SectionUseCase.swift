//
//  SectionUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - SectionUseCase Type

final class SectionUseCase {
    typealias T = SectionRepository
    let repository = SectionRepository()
}

// MARK: - UseCase Implementation

extension SectionUseCase: UseCase {
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch endpoint {
        case .getSections:
            let completion = completion as? ((Result<SectionHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return repository.getAll(cached: { _ in }, completion: completion)
        }
    }
    
    func request<T>(endpoint: Endpoints, for response: T.Type) async -> T? where T: Decodable {
        switch endpoint {
        case .getSections:
            return await repository.getAll()
        }
    }
}

// MARK: - Endpoints Type

extension SectionUseCase {
    enum Endpoints {
        case getSections
    }
}

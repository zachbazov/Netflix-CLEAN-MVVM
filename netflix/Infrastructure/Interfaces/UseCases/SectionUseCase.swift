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
    func request<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        let completion = completion as? ((Result<SectionHTTPDTO.Response, Error>) -> Void) ?? { _ in }
        return repository.getAll(cached: { _ in }, completion: completion)
    }
    
    func request<T>(for response: T.Type) async -> T? where T: Decodable {
        switch response {
        case is SectionHTTPDTO.Response.Type:
            return await repository.getAll()
        default: return nil
        }
    }
}

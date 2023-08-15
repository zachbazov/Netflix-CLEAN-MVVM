//
//  SectionUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - SectionUseCase Type

final class SectionUseCase {
    let repository: SectionRepository
    
    init(repository: SectionRepository) {
        self.repository = repository
    }
}

// MARK: - Endpoints Type

extension SectionUseCase {
    enum Endpoints {
        case getSections
    }
}

// MARK: - UseCase Implementation

extension SectionUseCase: UseCase {
    func request<T>(endpoint: Endpoints,
                    for response: T.Type,
                    request: Any?,
                    cached: @escaping (T?) -> Void,
                    completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch endpoint {
        case .getSections:
            return repository.find(request: request, cached: cached, completion: completion)
        }
    }
}

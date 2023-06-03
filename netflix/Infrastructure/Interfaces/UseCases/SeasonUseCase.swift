//
//  SeasonUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - SeasonUseCase Type

final class SeasonUseCase {
    let repository: SeasonRepository
    
    init(repository: SeasonRepository) {
        self.repository = repository
    }
}

// MARK: - Endpoints Type

extension SeasonUseCase {
    enum Endpoints {
        case getSeason
    }
}

// MARK: - UseCase Implementation

extension SeasonUseCase: UseCase {
    func request<T>(endpoint: Endpoints,
                    for response: T.Type,
                    request: Any?,
                    cached: @escaping (T?) -> Void,
                    completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch endpoint {
        case .getSeason:
            return repository.find(request: request, cached: cached, completion: completion)
        }
    }
    
    func request<T>(endpoint: Endpoints, for response: T.Type, request: Any?) async -> T? where T: Decodable {
        return nil
    }
}

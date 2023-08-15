//
//  ListUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - ListUseCase Type

final class ListUseCase {
    let repository: ListRepository
    
    init(repository: ListRepository) {
        self.repository = repository
    }
}

// MARK: - Endpoints Type

extension ListUseCase {
    enum Endpoints {
        case getList
        case updateList
    }
}

// MARK: - UseCase Implementation

extension ListUseCase: UseCase {
    func request<T>(endpoint: Endpoints,
                    for response: T.Type,
                    request: Any?,
                    cached: @escaping (T?) -> Void,
                    completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        switch endpoint {
        case .getList:
            return repository.find(request: request, cached: cached, completion: completion)
        case .updateList:
            return repository.update(request: request, completion: completion)
        }
    }
}

//
//  ListUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - ListUseCase Type

final class ListUseCase {
    typealias T = ListRepository
    let repository = ListRepository()
}

// MARK: - UseCase Implementation

extension ListUseCase: UseCase {
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch endpoint {
        case .getList:
            guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
            let completion = completion as? ((Result<ListHTTPDTO.GET.Response, Error>) -> Void) ?? { _ in }
            return repository.getOne(request: request, cached: { _ in }, completion: completion)
        case .updateList:
            guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
            let completion = completion as? ((Result<ListHTTPDTO.PATCH.Response, Error>) -> Void) ?? { _ in }
            return repository.updateOne(request: request, completion: completion)
        }
    }
    
    func request<T, U>(endpoint: Endpoints,
                       for response: T.Type,
                       request: U) async -> T? where T : Decodable {
        switch endpoint {
        case .getList:
            guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
            return await repository.getOne(request: request)
        case .updateList:
            guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
            return await repository.updateOne(request: request)
        }
    }
}

// MARK: - Endpoints Type

extension ListUseCase {
    enum Endpoints {
        case getList
        case updateList
    }
}

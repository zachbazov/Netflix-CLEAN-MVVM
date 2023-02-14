//
//  DetailUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 12/10/2022.
//

import Foundation

// MARK: - DetailUseCaseProtocol Protocol

private protocol DetailUseCaseProtocol {
    var seasonsRepository: SeasonRepository { get }
    
    func execute<T>(for response: T.Type,
                    with request: SeasonHTTPDTO.Request,
                    completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable?
}

// MARK: - DetailUseCase Type

final class DetailUseCase {
    fileprivate let seasonsRepository: SeasonRepository
    
    required init(seasonsRepository: SeasonRepository) {
        self.seasonsRepository = seasonsRepository
    }
}

// MARK: - DetailUseCaseProtocol Implementation

extension DetailUseCase: DetailUseCaseProtocol {
    private func request<T>(for response: T.Type,
                            request: SeasonHTTPDTO.Request,
                            completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return seasonsRepository.getSeason(request: request, completion: completion)
    }
    
    func execute<T>(for response: T.Type,
                    with request: SeasonHTTPDTO.Request,
                    completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return self.request(for: response, request: request, completion: completion)
    }
}

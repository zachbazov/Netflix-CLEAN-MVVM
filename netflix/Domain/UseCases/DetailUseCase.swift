//
//  DetailUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 12/10/2022.
//

import Foundation

// MARK: - DetailUseCase Type

final class DetailUseCase {
    
    // MARK: Properties
    
    private let seasonsRepository: SeasonRepository
    
    // MARK: Initializer
    
    init(seasonsRepository: SeasonRepository) {
        self.seasonsRepository = seasonsRepository
    }
}

// MARK: - Methods

extension DetailUseCase {
    private func request<T>(for response: T.Type,
                            with request: SeasonRequestDTO.GET,
                            completion: @escaping (Result<SeasonResponse.GET, Error>) -> Void) -> Cancellable? {
        return seasonsRepository.getSeason(with: request) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func execute<T>(for response: T.Type,
                    with request: SeasonRequestDTO.GET,
                    completion: @escaping (Result<SeasonResponse.GET, Error>) -> Void) -> Cancellable? {
        return self.request(for: response, with: request, completion: completion)
    }
}

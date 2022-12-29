//
//  SeasonRepository.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonRepository Type

struct SeasonRepository {
    let dataTransferService: DataTransferService
}

// MARK: - Methods

extension SeasonRepository {
    func getSeason(with request: SeasonRequestDTO.GET,
                   completion: @escaping (Result<SeasonResponseDTO.GET, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.MediaRepository.getSeason(with: request)
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}

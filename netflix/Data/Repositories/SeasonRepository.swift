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

// MARK: - SeasonRepositoryProtocol Implementation

extension SeasonRepository: SeasonRepositoryProtocol {
    func getSeason(request: SeasonHTTPDTO.Request,
                   completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getSeason(with: request)
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

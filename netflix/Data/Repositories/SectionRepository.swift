//
//  SectionRepository.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import Foundation

// MARK: - SectionsRepositoryEndpoints Protocol

protocol SectionsRepositoryEndpoints {
    static func getAllSections() -> Endpoint<SectionHTTPDTO.Response>
}

// MARK: - SectionRepository Type

struct SectionRepository {
    let dataTransferService: DataTransferService
}

// MARK: - Methods

extension SectionRepository {
    func getAll(completion: @escaping (Result<SectionHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getAllSections()
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

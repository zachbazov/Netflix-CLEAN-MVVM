//
//  SectionRepository.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import Foundation

// MARK: - SectionsRepositoryRouting Type

protocol SectionsRepositoryRouting {
    static func getAllSections() -> Endpoint<SectionHTTPDTO.Response>
}

// MARK: - SectionRepository Type

final class SectionRepository: Repository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - SectionRepositoryProtocol Implementation

extension SectionRepository {
    func getAll<T>(cached: @escaping (T?) -> Void, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T : Decodable {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getAllSections()
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                completion(.success(response as! T))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    func getAll<T>() async -> T? where T: Decodable {
        let endpoint = APIEndpoint.getAllSections()
        let result = await self.dataTransferService.request(with: endpoint)
        if case let .success(response) = result {
            return response as? T
        }
        return nil
    }
    
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        return nil
    }
}

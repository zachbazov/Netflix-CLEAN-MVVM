//
//  SeasonRepository.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonRepository Type

final class SeasonRepository: Repository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - SeasonRepositoryProtocol Implementation

extension SeasonRepository {
    func getAll<T>(cached: @escaping (T?) -> Void, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func getAll<T>() async -> T? where T: Decodable {
        return nil
    }
    
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        guard let request = request as? SeasonHTTPDTO.Request else { return nil }
        
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getSeason(with: request)
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
}

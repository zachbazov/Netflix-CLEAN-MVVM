//
//  SeasonRepository.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonRepositoryRouting Type

protocol SeasonRepositoryRouting {
    static func getSeason(with request: SeasonHTTPDTO.Request) -> Endpoint<SeasonHTTPDTO.Response>
}

// MARK: - SeasonRepository Type

final class SeasonRepository: Repository {
    let dataTransferService: DataServiceTransferring
    
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    init(dataTransferService: DataServiceTransferring) {
        self.dataTransferService = dataTransferService
    }
}

// MARK: - SeasonRepositoryRouting Implementation

extension SeasonRepository: SeasonRepositoryRouting {
    static func getSeason(with request: SeasonHTTPDTO.Request) -> Endpoint<SeasonHTTPDTO.Response> {
        return Endpoint(path: "api/v1/seasons",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["slug": request.slug ?? "", "season": request.season ?? 1])
    }
}

// MARK: - SeasonRepositoryProtocol Implementation

extension SeasonRepository {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        guard let request = request as? SeasonHTTPDTO.Request else { return nil }
        
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = SeasonRepository.getSeason(with: request)
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

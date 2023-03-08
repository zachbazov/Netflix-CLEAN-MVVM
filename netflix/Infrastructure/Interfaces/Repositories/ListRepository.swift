//
//  ListRepository.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListRepository Type

final class ListRepository: Repository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - ListRepositoryProtocol Implementation

extension ListRepository {
    func getAll<T>(cached: @escaping (T?) -> Void, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable {
        return nil
    }
    
    func getAll<T>() async -> T? where T: Decodable {
        return nil
    }
    
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
        let requestDTO = ListHTTPDTO.GET.Request(user: request.user)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getMyList(with: requestDTO)
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
    
    func updateOne(request: ListHTTPDTO.PATCH.Request,
                   completion: @escaping (Result<ListHTTPDTO.PATCH.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.updateMyList(with: request)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            completion: { result in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        
        return task
    }
}

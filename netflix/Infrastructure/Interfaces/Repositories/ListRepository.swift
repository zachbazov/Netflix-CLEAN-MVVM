//
//  ListRepository.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListRepositoryRouting Type

protocol ListRepositoryRouting {
    static func getMyList(with request: ListHTTPDTO.GET.Request) -> Endpoint<ListHTTPDTO.GET.Response>
    static func updateMyList(with request: ListHTTPDTO.PATCH.Request) -> Endpoint<ListHTTPDTO.PATCH.Response>
}

// MARK: - ListRepository Type

final class ListRepository: Repository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - ListRepositoryProtocol Implementation

extension ListRepository {
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
    
    func updateOne<T, U>(request: U,
                         completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
        
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.updateMyList(with: request)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            completion: { result in
                switch result {
                case .success(let response):
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        
        return task
    }
    
    func getOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
        
        let endpoint = APIEndpoint.getMyList(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response as? T
        }
        
        return nil
    }
    
    func updateOne<T, U>(request: U) async -> T? where T: Decodable, U: Decodable {
        guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
        
        let endpoint = APIEndpoint.updateMyList(with: request)
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response as? T
        }
        
        return nil
    }
}

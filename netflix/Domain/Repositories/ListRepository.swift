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
    var dataTransferService: DataServiceTransferring
    
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    init(dataTransferService: DataServiceTransferring) {
        self.dataTransferService = dataTransferService
    }
}

// MARK: - ListRepositoryRouting Implementation

extension ListRepository: ListRepositoryRouting {
    static func getMyList(with request: ListHTTPDTO.GET.Request) -> Endpoint<ListHTTPDTO.GET.Response> {
        return Endpoint(path: "api/v1/mylists",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["user": request.user._id ?? ""])
    }
    
    static func updateMyList(with request: ListHTTPDTO.PATCH.Request) -> Endpoint<ListHTTPDTO.PATCH.Response> {
        return Endpoint(path: "api/v1/mylists",
                        method: .patch,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["user": request.user],
                        bodyParameters: ["user": request.user,
                                         "media": request.media],
                        bodyEncoding: .jsonSerializationData)
    }
}


// MARK: - ListRepositoryProtocol Implementation

extension ListRepository {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
        
        let requestDTO = ListHTTPDTO.GET.Request(user: request.user)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = ListRepository.getMyList(with: requestDTO)
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
    
    func update<T>(request: Any?, completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
        
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = ListRepository.updateMyList(with: request)
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
}

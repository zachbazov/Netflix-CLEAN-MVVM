//
//  ListRepository.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListRepositoryEndpoints Protocol

protocol ListRepositoryEndpoints {
    static func getMyList(with request: ListHTTPDTO.GET.Request) -> Endpoint<ListHTTPDTO.GET.Response>
    static func updateMyList(with request: ListHTTPDTO.PATCH.Request) -> Endpoint<ListHTTPDTO.PATCH.Response>
}

// MARK: - ListRepository Type

struct ListRepository {
    let dataTransferService: DataTransferService
}

// MARK: - Methods

extension ListRepository {
    func getOne(request: ListHTTPDTO.GET.Request,
                completion: @escaping (Result<ListHTTPDTO.GET.Response, Error>) -> Void) -> Cancellable? {
        let requestDTO = ListHTTPDTO.GET.Request(user: request.user)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getMyList(with: requestDTO)
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

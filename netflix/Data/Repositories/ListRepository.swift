//
//  ListRepository.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListRepositoryEndpoints Protocol

protocol ListRepositoryEndpoints {
    static func getAllMyLists() -> Endpoint<ListResponseDTO.GET>
    static func getMyList(with request: ListRequestDTO.GET) -> Endpoint<ListResponseDTO.GET>
    static func createMyList(with request: ListRequestDTO.POST) -> Endpoint<ListResponseDTO.POST>
    static func updateMyList(with request: ListRequestDTO.PATCH) -> Endpoint<ListResponseDTO.PATCH>
}

// MARK: - ListRepository Type

struct ListRepository {
    let dataTransferService: DataTransferService
}

// MARK: - Methods

extension ListRepository {
    func getAll(completion: @escaping (Result<ListResponseDTO.GET, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.ListRepository.getAllMyLists()
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
    
    func getOne(request: ListRequestDTO.GET,
                completion: @escaping (Result<ListResponseDTO.GET, Error>) -> Void) -> Cancellable? {
        let requestDTO = ListRequestDTO.GET(user: request.user)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.ListRepository.getMyList(with: requestDTO)
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
    
    func createOne(request: ListRequestDTO.POST,
                   completion: @escaping (Result<ListResponseDTO.POST, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.ListRepository.createMyList(with: request)
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
    
    func updateOne(request: ListRequestDTO.PATCH,
                   completion: @escaping (Result<ListResponseDTO.PATCH, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.ListRepository.updateMyList(with: request)
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

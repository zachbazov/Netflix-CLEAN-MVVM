//
//  MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 17/10/2022.
//

import Foundation

// MARK: - MediaRepository Type

final class MediaRepository: Repository {
    let dataTransferService: DataTransferService = Application.app.services.dataTransfer
    let responseStorage: MediaResponseStorage = Application.app.stores.mediaResponses
    var task: Cancellable? { willSet { task?.cancel() } }
}

// MARK: - MediaRepositoryProtocol Implementation

extension MediaRepository {
    func getAll<T>(cached: @escaping (T?) -> Void,
                   completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable {
        let task = RepositoryTask()
        
        responseStorage.getResponse { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(responseDTO?) = result {
                return cached(responseDTO as? T)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.getAllMedia()
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.responseStorage.save(response: response)
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func getAll<T>() async -> T? where T: Decodable {
        guard let cached = await responseStorage.getResponse() else {
            let endpoint = APIEndpoint.getAllMedia()
            let result = await dataTransferService.request(with: endpoint)
            
            if case let .success(response) = result {
                responseStorage.save(response: response)
                return response as? T
            }
            
            return nil
        }
        
        return cached as? T
    }
    
    func getOne<T, U>(request: U,
                      cached: @escaping (T?) -> Void,
                      completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable, U: Decodable {
        guard let request = request as? MediaHTTPDTO.Request else { return nil }
        let requestDTO = MediaHTTPDTO.Request(id: request.id, slug: request.slug)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getMedia(with: requestDTO)
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
    
    func search(requestDTO: SearchHTTPDTO.Request,
                cached: @escaping (SearchHTTPDTO.Response) -> Void,
                completion: @escaping (Result<SearchHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.searchMedia(with: requestDTO)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            completion: { result in
                if case let .success(responseDTO) = result {
                    completion(.success(responseDTO))
                } else if case let .failure(error) = result {
                    completion(.failure(error))
                }
            })
        
        return task
    }
    
    func getUpcomings(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let params = ["isNewRelease": true]
        let requestDTO = NewsHTTPDTO.Request(queryParams: params)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getUpcomingMedia(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint, completion: { result in
            if case let .success(responseDTO) = result {
                completion(.success(responseDTO))
            } else if case let .failure(error) = result {
                completion(.failure(error))
            }
        })
        
        return task
    }
    
    func getTopSearches(completion: @escaping (Result<SearchHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getTopSearchedMedia()
        task.networkTask = dataTransferService.request(with: endpoint, completion: { result in
            if case let .success(responseDTO) = result {
                completion(.success(responseDTO))
            } else if case let .failure(error) = result {
                completion(.failure(error))
            }
        })
        
        return task
    }
    
    func getTopSeaches() async -> SearchHTTPDTO.Response? {
        let endpoint = APIEndpoint.getTopSearchedMedia()
        let result = await dataTransferService.request(with: endpoint)
        
        if case let .success(response) = result {
            return response
        }
        
        return nil
    }
}

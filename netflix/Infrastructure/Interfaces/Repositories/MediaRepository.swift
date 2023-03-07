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

extension MediaRepository: MediaRepositoryProtocol {
    func getAll() async throws -> MediaHTTPDTO.Response? {
        let endpoint = APIEndpoint.getAllMedia()
        let result = try await self.dataTransferService.request(with: endpoint)
        if case let .success(response) = result {
            return response
        }
        return nil
    }
    func getAll(cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        responseStorage.getResponse { [weak self] result in
            guard let self = self else { return }
            if case let .success(responseDTO?) = result {
                return cached(responseDTO)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = APIEndpoint.getAllMedia()
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.responseStorage.save(response: response)
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func getOne(request: MediaHTTPDTO.Request,
                cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let requestDTO = MediaHTTPDTO.Request(id: request.id, slug: request.slug)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getMedia(with: requestDTO)
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
    
    func search(requestDTO: SearchHTTPDTO.Request,
                cached: @escaping ([Media]) -> Void,
                completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.searchMedia(with: requestDTO)
        task.networkTask = Application.app.services.dataTransfer.request(
            with: endpoint,
            completion: { result in
                if case let .success(responseDTO) = result {
                    let media = responseDTO.data.toDomain()
                    completion(.success(media))
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
        let dataTransferService = Application.app.services.dataTransfer
        
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
    
    func getTopSearches(completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let requestDTO = MediaHTTPDTO.Request(id: nil, slug: nil)
        let task = RepositoryTask()
        let dataTransferService = Application.app.services.dataTransfer
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.getTopSearchedMedia(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint, completion: { result in
            if case let .success(responseDTO) = result {
                completion(.success(responseDTO))
            } else if case let .failure(error) = result {
                completion(.failure(error))
            }
        })
        
        return task
    }
    func getTopSeaches() async throws -> MediaHTTPDTO.Response? {
        let requestDTO = MediaHTTPDTO.Request(id: nil, slug: nil)
        let endpoint = APIEndpoint.getTopSearchedMedia(with: requestDTO)
        let result = try await self.dataTransferService.request(with: endpoint)
        if case let .success(response) = result {
            return response
        }
        return nil
    }
}

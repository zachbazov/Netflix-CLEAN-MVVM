//
//  MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 17/10/2022.
//

import Foundation

// MARK: - MediaRepository Type

struct MediaRepository {
    let dataTransferService: DataTransferService
    let cache: MediaResponseStorage = Application.current.mediaResponseCache
}

// MARK: - MediaRepositoryProtocol Implementation

extension MediaRepository: MediaRepositoryProtocol {
    func getAll(cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        cache.getResponse { result in
            if case let .success(responseDTO?) = result {
                return cached(responseDTO)
            }
            
            guard !task.isCancelled else { return }
            let endpoint = APIEndpoint.getAllMedia()
            task.networkTask = dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.cache.save(response: response)
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
        task.networkTask = Application.current.dataTransferService.request(
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
        let dataTransferService = Application.current.dataTransferService
        
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
}

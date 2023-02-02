//
//  MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 17/10/2022.
//

import Foundation

// MARK: - MediaRepositoryEndpoints Protocol

protocol MediaRepositoryEndpoints: SearchRepositoryEndpoints, NewsRepositoryEndpoints {
    static func getAllMedia() -> Endpoint<MediaHTTPDTO.Response>
    static func getMedia(with request: MediaHTTPDTO.Request) -> Endpoint<MediaHTTPDTO.Response>
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response>
}

// MARK: - SearchRepositoryEndpoints Protocol

protocol SearchRepositoryEndpoints {
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response>
}

// MARK: - NewsRepositoryEndpoints Protocol

protocol NewsRepositoryEndpoints {
    static func getUpcomingMedia(with request: NewsHTTPDTO.Request) -> Endpoint<NewsHTTPDTO.Response>
}

// MARK: - MediaRepository Type

struct MediaRepository {
    let dataTransferService: DataTransferService
    let cache: MediaResponseStorage = Application.current.mediaResponseCache
}

// MARK: - Methods

extension MediaRepository {
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
}

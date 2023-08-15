//
//  MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 17/10/2022.
//

import Foundation

// MARK: - MediaRepositoryRouting Type

protocol MediaRepositoryRouting: SearchRepositoryRouting, NewsRepositoryRouting {
    static func getAllMedia() -> Endpoint<MediaHTTPDTO.Response>
    static func getMedia(with request: MediaHTTPDTO.Request) -> Endpoint<MediaHTTPDTO.Response>
}

// MARK: - SearchRepositoryRouting Type

protocol SearchRepositoryRouting {
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response>
}

// MARK: - NewsRepositoryRouting Type

protocol NewsRepositoryRouting {
    static func getUpcomingMedia(with request: NewsHTTPDTO.Request) -> Endpoint<NewsHTTPDTO.Response>
}

// MARK: - MediaRepository Type

final class MediaRepository: Repository {
    let dataTransferService: DataServiceTransferring
    
    let persistentStore: MediaHTTPResponseStore
    
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    init(dataTransferService: DataServiceTransferring, persistentStore: MediaHTTPResponseStore) {
        self.dataTransferService = dataTransferService
        self.persistentStore = persistentStore
    }
}

// MARK: - MediaRepositoryRouting Implementation

extension MediaRepository: MediaRepositoryRouting {
    static func getAllMedia() -> Endpoint<MediaHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"])
    }
    
    static func getMedia(with request: MediaHTTPDTO.Request) -> Endpoint<MediaHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: request.slug != nil ? ["slug": request.slug ?? ""] : ["id": request.id ?? ""])
    }
    
    static func getUpcomingMedia(with request: NewsHTTPDTO.Request) -> Endpoint<NewsHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: request.queryParams)
    }
    
    static func getTopSearchedMedia() -> Endpoint<SearchHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["timesSearched": 1, "limit": 20])
    }
    
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media/search",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["slug": request.regex, "title": request.regex])
    }
}

// MARK: - RepositoryRequestable Implementation

extension MediaRepository {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        let task = RepositoryTask()
        
        persistentStore.getResponse { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(response?) = result {
                return cached(response as? T)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = MediaRepository.getAllMedia()
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.persistentStore.save(response: response)
                    
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func search(requestDTO: SearchHTTPDTO.Request,
                cached: @escaping (SearchHTTPDTO.Response) -> Void,
                completion: @escaping (Result<SearchHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = MediaRepository.searchMedia(with: requestDTO)
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
    
    func getUpcomings(completion: @escaping (Result<NewsHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let params = ["isNewRelease": true]
        let requestDTO = NewsHTTPDTO.Request(queryParams: params)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = MediaRepository.getUpcomingMedia(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint, completion: { result in
            if case let .success(responseDTO) = result {
                completion(.success(responseDTO))
            } else if case let .failure(error) = result {
                completion(.failure(error))
            }
        })
        
        return task
    }
    
    func getTopSearches(completion: @escaping (Result<SearchHTTPDTO.Response, DataTransferError>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = MediaRepository.getTopSearchedMedia()
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

//
//  MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 17/10/2022.
//

import Foundation

// MARK: - MediaRepositoryEndpoints Protocol

protocol MediaRepositoryEndpoints {
    static func getAllMedia() -> Endpoint<MediaResponseDTO>
    static func getMedia(with request: MediaRequestDTO) -> Endpoint<MediaResponseDTO>
    static func searchMedia(with request: SearchRequestDTO) -> Endpoint<SearchResponseDTO>
    static func getSeason(with request: SeasonRequestDTO.GET) -> Endpoint<SeasonResponseDTO.GET>
}

// MARK: - MediaRepository Type

struct MediaRepository {
    let dataTransferService: DataTransferService
    var cache: MediaResponseStorage { Application.current.mediaResponseCache }
}

// MARK: - Methods

extension MediaRepository {
    func getAll(cached: @escaping (MediaResponseDTO?) -> Void,
                completion: @escaping (Result<MediaResponseDTO, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        cache.getResponse { result in
            if case let .success(responseDTO?) = result {
                return cached(responseDTO)
            }
            
            guard !task.isCancelled else { return }
            let endpoint = APIEndpoint.MediaRepository.getAllMedia()
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
    
    func getOne(request: MediaRequestDTO,
                cached: @escaping (MediaResponseDTO?) -> Void,
                completion: @escaping (Result<MediaResponseDTO, Error>) -> Void) -> Cancellable? {
        let requestDTO = MediaRequestDTO(id: request.id, slug: request.slug)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.MediaRepository.getMedia(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
//                self.cache.save(response: response)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}

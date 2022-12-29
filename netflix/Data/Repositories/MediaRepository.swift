//
//  MediaRepository.swift
//  netflix
//
//  Created by Zach Bazov on 17/10/2022.
//

import Foundation

// MARK: - MediaRepositoryEndpoints Protocol

protocol MediaRepositoryEndpoints {
    static func getAllMedia() -> Endpoint<MediaResponseDTO.GET.Many>
    static func getMedia(with request: MediaRequestDTO.GET.One) -> Endpoint<MediaResponseDTO.GET.One>
    static func searchMedia(with request: SearchRequestDTO) -> Endpoint<SearchResponseDTO>
    static func getSeason(with request: SeasonRequestDTO.GET) -> Endpoint<SeasonResponseDTO.GET>
}

// MARK: - MediaRepository Type

struct MediaRepository {
    let dataTransferService: DataTransferService
    let cache: MediaResponseStorage
}

// MARK: - Methods

extension MediaRepository {
    func getAll(completion: @escaping (Result<MediaResponseDTO.GET.Many, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.MediaRepository.getAllMedia()
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
    
    func getOne(request: MediaRequestDTO.GET.One,
                cached: @escaping (MediaResponseDTO.GET.One?) -> Void,
                completion: @escaping (Result<MediaResponseDTO.GET.One, Error>) -> Void) -> Cancellable? {
        let requestDTO = MediaRequestDTO.GET.One(user: request.user,
                                             id: request.id,
                                             slug: request.slug)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoint.MediaRepository.getMedia(with: requestDTO)
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                self.cache.save(response: response, for: requestDTO)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}

//
//  NewsUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

final class NewsUseCase {
    private let mediaRepository: MediaRepository
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
    
    func execute(completion: @escaping (Result<NewsResponseDTO, Error>) -> Void) -> Cancellable? {
            return fetchUpcomingMedia { result in
                if case let .success(responseDTO) = result {
                    completion(.success(responseDTO))
                } else if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }
        }
    
    func fetchUpcomingMedia(completion: @escaping (Result<NewsResponseDTO, Error>) -> Void) -> Cancellable? {
            let params = ["isNewRelease": true]
            let requestDTO = NewsRequestDTO(queryParams: params)
            let task = RepositoryTask()
            let dataTransferService = Application.current.dataTransferService
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = APIEndpoint.MediaRepository.getUpcomingMedia(with: requestDTO)
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

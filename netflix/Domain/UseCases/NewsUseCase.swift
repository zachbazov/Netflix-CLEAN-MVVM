//
//  NewsUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - NewsUseCase Type

final class NewsUseCase {
    
    // MARK: Properties
    
    private let mediaRepository: MediaRepository
    
    // MARK: Initializer
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - Methods

extension NewsUseCase {
    private func execute(completion: @escaping (Result<NewsResponseDTO, Error>) -> Void) -> Cancellable? {
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

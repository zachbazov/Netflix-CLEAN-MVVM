//
//  NewsUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - NewsUseCase Type

final class NewsUseCase {
    private let mediaRepository: MediaRepository
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - Methods

extension NewsUseCase {
    private func execute(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
            return fetchUpcomingMedia { result in
                if case let .success(responseDTO) = result {
                    completion(.success(responseDTO))
                } else if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }
        }
    
    func fetchUpcomingMedia(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
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

//
//  SearchUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

// MARK: - SearchUseCase Type

final class SearchUseCase {
    private let mediaRepository: MediaRepository
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - Methods

extension SearchUseCase {
    func execute(requestDTO: SearchHTTPDTO.Request,
                 cached: @escaping ([Media]) -> Void,
                 completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {
        return fetchMediaList(
            requestDTO: requestDTO,
            cached: { _ in },
            completion: { result in
                if case let .success(data) = result {
                    completion(.success(data))
                }
            })
    }
    
    private func fetchMediaList(requestDTO: SearchHTTPDTO.Request,
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
}

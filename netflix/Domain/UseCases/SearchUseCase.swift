//
//  SearchUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

// MARK: - SearchUseCaseRequestValue Type

struct SearchUseCaseRequestValue {
    let query: MediaQuery
    let page: Int
}

// MARK: - MediaQuery Type

struct MediaQuery: Equatable {
    let query: String
}

// MARK: - SearchUseCase Type

final class SearchUseCase {
    
    // MARK: Properties
    
    private let mediaRepository: MediaRepository
    
    // MARK: Initializer
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - Methods

extension SearchUseCase {
    func execute(
        requestValue: SearchUseCaseRequestValue,
        cached: @escaping (MediaPage) -> Void,
        completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable? {
            return fetchMediaList(
                query: requestValue.query,
                page: requestValue.page,
                cached: { _ in },
                completion: { result in
                    if case let .success(mediaPage) = result {
                        completion(.success(mediaPage))
                    }
                })
            }
    
    func fetchMediaList(
        query: MediaQuery,
        page: Int,
        cached: @escaping (MediaPage) -> Void,
        completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable? {
            let requestDTO = SearchRequestDTO(title: query.query, page: nil)
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = APIEndpoint.MediaRepository.searchMedia(with: requestDTO)
            task.networkTask = Application.current.dataTransferService.request(with: endpoint, completion: { result in
                if case let .success(responseDTO) = result {
                    let mediaPage = MediaPage(page: 0,
                                              totalPages: 1,
                                              media: responseDTO.data.map { $0.toDomain() })
                    completion(.success(mediaPage))
                } else if case let .failure(error) = result {
                    completion(.failure(error))
                }
            })
            
            return task
        }
}

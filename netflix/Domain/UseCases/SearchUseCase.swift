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
}

// MARK: - MediaQuery Type

struct MediaQuery: Equatable {
    let query: String
}

// MARK: - SearchUseCase Type

final class SearchUseCase {
    private let mediaRepository: MediaRepository
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - Methods

extension SearchUseCase {
    func execute(
        requestValue: SearchUseCaseRequestValue,
        cached: @escaping ([Media]) -> Void,
        completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {
            return fetchMediaList(
                query: requestValue.query,
                cached: { _ in },
                completion: { result in
                    if case let .success(data) = result {
                        completion(.success(data))
                    }
                })
            }
    
    private func fetchMediaList(
        query: MediaQuery,
        cached: @escaping ([Media]) -> Void,
        completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {
            let requestDTO = SearchHTTPDTO.Request(regex: query.query)
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = APIEndpoint.searchMedia(with: requestDTO)
            task.networkTask = Application.current.dataTransferService.request(
                with: endpoint,
                completion: { result in
                    if case let .success(responseDTO) = result {
                        let media = responseDTO.data.map { $0.toDomain() }
                        completion(.success(media))
                    } else if case let .failure(error) = result {
                        completion(.failure(error))
                    }
                })
            
            return task
        }
}

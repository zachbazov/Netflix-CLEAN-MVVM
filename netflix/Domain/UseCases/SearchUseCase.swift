//
//  SearchUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

final class SearchUseCase {
    private let mediaRepository: MediaRepository
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
    
    func execute(
        requestValue: SearchUseCaseRequestValue,
        cached: @escaping (MediaPage) -> Void,
        completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable? {
            return fetchMediaList(query: requestValue.query, page: requestValue.page) { mediaPage in
                print("cached", mediaPage)
            } completion: { result in
                if case let .success(mediaPage) = result {
                    completion(.success(mediaPage))
                }
            }
        }
    
    func fetchMediaList(
        query: MediaQuery,
        page: Int,
        cached: @escaping (MediaPage) -> Void,
        completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable? {
            let requestDTO = SearchRequestDTO(slug: query.query, page: nil) //, page: page
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = getMedia(with: requestDTO)
            task.networkTask = Application.current.dataTransferService.request(with: endpoint, completion: { result in
                if case let .success(responseDTO) = result {
                    completion(.success(MediaPage(page: 0, totalPages: 1, media: responseDTO.data.map { $0.toDomain() } )))
                } else if case let .failure(error) = result {
                    completion(.failure(error))
                }
            })
            
            return task
        }
    
    func getMedia(with mediaRequestDTO: SearchRequestDTO) -> Endpoint<SearchResponseDTO> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        queryParametersEncodable: mediaRequestDTO)
    }
}

struct SearchUseCaseRequestValue {
    let query: MediaQuery
    let page: Int
}

struct MediaQuery: Equatable {
    let query: String
}

//
//  SearchUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

// MARK: - SearchUseCaseProtocol Protocol

private protocol SearchUseCaseProtocol {
    var mediaRepository: MediaRepository { get }
    
    func execute(requestDTO: SearchHTTPDTO.Request,
                 cached: @escaping ([Media]) -> Void,
                 completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable?
}

// MARK: - SearchUseCase Type

final class SearchUseCase {
    fileprivate let mediaRepository: MediaRepository
    
    required init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - SearchUseCaseProtocol Implementation

extension SearchUseCase: SearchUseCaseProtocol {
    private func request(requestDTO: SearchHTTPDTO.Request,
                         cached: @escaping ([Media]) -> Void,
                         completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {
        return mediaRepository.search(requestDTO: requestDTO, cached: cached, completion: completion)
    }
    
    func execute(requestDTO: SearchHTTPDTO.Request,
                 cached: @escaping ([Media]) -> Void,
                 completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {
        return request(requestDTO: requestDTO, cached: cached, completion: completion)
    }
}

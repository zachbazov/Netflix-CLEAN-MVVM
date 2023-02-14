//
//  NewsUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - NewsUseCaseProtocol Protocol

private protocol NewsUseCaseProtocol {
    var mediaRepository: MediaRepository { get }
    
    func execute(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable?
}

// MARK: - NewsUseCase Type

final class NewsUseCase {
    fileprivate let mediaRepository: MediaRepository
    
    required init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}

// MARK: - NewsUseCaseProtocol Implementation

extension NewsUseCase: NewsUseCaseProtocol {
    private func request(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return mediaRepository.getUpcomings(completion: completion)
    }
    
    func execute(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return request(completion: completion)
    }
}

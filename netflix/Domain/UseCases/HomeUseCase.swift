//
//  HomeUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 06/09/2022.
//

import Foundation

// MARK: - HomeUseCaseProtocol Protocol

private protocol HomeUseCaseProtocol {
    var sectionsRepository: SectionRepository { get }
    var mediaRepository: MediaRepository { get }
    var listRepository: ListRepository { get }
    
    func execute<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable?
}

// MARK: - HomeUseCase Type

final class HomeUseCase {
    fileprivate let sectionsRepository: SectionRepository
    fileprivate let mediaRepository: MediaRepository
    fileprivate let listRepository: ListRepository
    
    required init(sectionsRepository: SectionRepository,
                  mediaRepository: MediaRepository,
                  listRepository: ListRepository) {
        self.sectionsRepository = sectionsRepository
        self.mediaRepository = mediaRepository
        self.listRepository = listRepository
    }
}

// MARK: - HomeUseCaseProtocol Implementation

extension HomeUseCase: HomeUseCaseProtocol {
    private func request<T, U>(for response: T.Type,
                               request: U? = nil,
                               cached: ((T?) -> Void)?,
                               completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is SectionHTTPDTO.Response.Type:
            let completion = completion as? ((Result<SectionHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return sectionsRepository.getAll(completion: completion)
        case is MediaHTTPDTO.Response.Type:
            let cached = cached as? ((MediaHTTPDTO.Response?) -> Void) ?? { _ in }
            let completion = completion as? ((Result<MediaHTTPDTO.Response, Error>) -> Void) ?? { _ in }
            return mediaRepository.getAll(cached: cached, completion: completion)
        case is ListHTTPDTO.GET.Response.Type:
            guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
            let completion = completion as? ((Result<ListHTTPDTO.GET.Response, Error>) -> Void) ?? { _ in }
            return listRepository.getOne(request: request, completion: completion)
        case is ListHTTPDTO.PATCH.Response.Type:
            guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
            let completion = completion as? ((Result<ListHTTPDTO.PATCH.Response, Error>) -> Void) ?? { _ in }
            return listRepository.updateOne(request: request, completion: completion)
        default: return nil
        }
    }
    
    func execute<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        return self.request(for: response,
                            request: request,
                            cached: cached!,
                            completion: completion!)
    }
}

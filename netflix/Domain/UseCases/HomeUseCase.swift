//
//  HomeUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 06/09/2022.
//

import Foundation

// MARK: - HomeUseCase Type

final class HomeUseCase {
    private let sectionsRepository: SectionRepository
    private let mediaRepository: MediaRepository
    private let listRepository: ListRepository
    
    init(sectionsRepository: SectionRepository,
         mediaRepository: MediaRepository,
         listRepository: ListRepository) {
        self.sectionsRepository = sectionsRepository
        self.mediaRepository = mediaRepository
        self.listRepository = listRepository
    }
}

// MARK: - Methods

extension HomeUseCase {
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

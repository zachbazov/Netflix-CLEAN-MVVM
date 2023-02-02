//
//  HomeUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 06/09/2022.
//

import Foundation

// MARK: - HomeUseCase Type

final class HomeUseCase {
    
    // MARK: Properties
    
    private let sectionsRepository: SectionRepository
    private(set) var mediaRepository: MediaRepository
    private(set) var listRepository: ListRepository
    
    // MARK: Initializer
    
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
    
    private func request(cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                         completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return mediaRepository.getAll(cached: cached, completion: completion)
    }
    
    func execute(cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                 completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        return request(cached: cached, completion: completion)
    }
    
    private func request<T, U>(for response: T.Type,
                               request: U? = nil,
                               cached: ((T?) -> Void)?,
                               completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is SectionHTTPDTO.Response.Type:
            return sectionsRepository.getAll { result in
                switch result {
                case .success(let response):
                    completion?(.success(response as! T))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        case is MediaHTTPDTO.Response.Type:
            switch request {
            case is Any.Type:
                return mediaRepository.getAll(
                    cached: { responseDTO in
                        cached?(responseDTO as? T)
                    },
                    completion: { result in
                        switch result {
                        case .success(let response):
                            completion?(.success(response as! T))
                        case .failure(let error):
                            completion?(.failure(error))
                        }
                    })
            case is MediaHTTPDTO.Request.Type:
                guard let request = request as? MediaHTTPDTO.Request else { return nil }
                let requestDTO = MediaHTTPDTO.Request(id: request.id, slug: request.slug)
                return mediaRepository.getOne(
                    request: requestDTO,
                    cached: { _ in },
                    completion: { result in
                        switch result {
                        case .success(let response):
                            completion?(.success(response as! T))
                        case .failure(let error):
                            completion?(.failure(error))
                        }
                    })
            default: return nil
            }
        case is ListHTTPDTO.GET.Response.Type:
            guard let request = request as? ListHTTPDTO.GET.Request else { return nil }
            return listRepository.getOne(
                request: request,
                completion: { result in
                    switch result {
                    case .success(let response):
                        completion?(.success(response as! T))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                })
        case is ListHTTPDTO.PATCH.Response.Type:
            guard let request = request as? ListHTTPDTO.PATCH.Request else { return nil }
            return listRepository.updateOne(request: request) { result in
                switch result {
                case .success(let response):
                    completion?(.success(response as! T))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        default: return nil
        }
    }
    
    func execute<T, U>(for response: T.Type,
                       request: U? = nil,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        return self.request(for: response,
                            request: request,
                            cached: cached ?? { _ in },
                            completion: completion ?? { _ in })
    }
}

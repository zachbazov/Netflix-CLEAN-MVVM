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
    private func request<T, U>(for response: T.Type,
                               request: U? = nil,
                               cached: ((T?) -> Void)?,
                               completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        switch response {
        case is SectionResponse.GET.Type:
            return sectionsRepository.getAll { result in
                switch result {
                case .success(let response):
                    cached?(response as? T)
                    completion?(.success(response.toDomain() as! T))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        case is MediaResponse.GET.Many.Type:
            return mediaRepository.getAll { result in
                switch result {
                case .success(let response):
                    cached?(response as? T)
                    completion?(.success(response.toDomain() as! T))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        case is MediaResponse.GET.One.Type:
            guard let request = request as? MediaRequestDTO.GET.One else { return nil }
            let requestDTO = MediaRequestDTO.GET.One(user: request.user,
                                                     id: request.id,
                                                     slug: request.slug)
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
        case is ListResponseDTO.GET.Type:
            guard let request = request as? ListRequestDTO.GET else { return nil }
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
        case is ListResponseDTO.PATCH.Type:
            guard let request = request as? ListRequestDTO.PATCH else { return nil }
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

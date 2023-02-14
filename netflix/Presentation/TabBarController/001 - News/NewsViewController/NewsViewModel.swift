//
//  NewsViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - NewsViewModel Type

final class NewsViewModel {
    var coordinator: NewsViewCoordinator?
    
    private lazy var repository: MediaRepository = createMediaRepository()
    private lazy var router = Router<MediaRepository>(repository: repository)
    
    let items: Observable<[NewsTableViewCellViewModel]> = Observable([])
    var isEmpty: Bool { return items.value.isEmpty }
    
    private func createMediaRepository() -> MediaRepository {
        let dataTransferService = Application.app.services.dataTransfer
        return MediaRepository(dataTransferService: dataTransferService)
    }
}

// MARK: - ViewModel Implementaiton

extension NewsViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - UI Setup

extension NewsViewModel {
    func viewDidLoad() {
        fetchUpcomingMedia()
    }
}

// MARK: - NewsUseCase Implementation

extension NewsViewModel {
    private func fetchUpcomingMedia() {
        repository.task = router.request(for: NewsHTTPDTO.Response.self, request: Any.self, cached: nil, completion: { [weak self] result in
            if case let .success(responseDTO) = result {
                self?.items.value = responseDTO.toCellViewModels()
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        })
    }
}

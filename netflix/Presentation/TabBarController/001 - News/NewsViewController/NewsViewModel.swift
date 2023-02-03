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
    private let useCase: NewsUseCase
    let items: Observable<[NewsTableViewCellViewModel]> = Observable([])
    var isEmpty: Bool { return items.value.isEmpty }
    private var mediaLoadTask: Cancellable? { willSet { mediaLoadTask?.cancel() } }
    /// Default initializer.
    /// Allocate `useCase` property and it's dependencies.
    init() {
        let dataTransferService = Application.current.dataTransferService
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService)
        self.useCase = NewsUseCase(mediaRepository: mediaRepository)
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
        mediaLoadTask = useCase.fetchUpcomingMedia { [weak self] result in
            if case let .success(responseDTO) = result {
                self?.items.value = responseDTO.toCellViewModels()
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        }
    }
}

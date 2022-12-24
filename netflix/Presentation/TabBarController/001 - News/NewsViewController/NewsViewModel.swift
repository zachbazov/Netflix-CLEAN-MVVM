//
//  NewsViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

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
        let cache = Application.current.mediaResponseCache
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService, cache: cache)
        self.useCase = NewsUseCase(mediaRepository: mediaRepository)
    }
}

extension NewsViewModel: ViewModel {
    func transform(input: Void) {}
}

extension NewsViewModel {
    func viewDidLoad() {
        fetchUpcomingMedia()
    }
}

extension NewsViewModel {
    private func fetchUpcomingMedia() {
        mediaLoadTask = useCase.fetchUpcomingMedia { [weak self] result in
            if case let .success(responseDTO) = result {
                self?.items.value = responseDTO.toCellViewModels()
            } else if case let .failure(error) = result {
                print(error)
            }
        }
    }
}

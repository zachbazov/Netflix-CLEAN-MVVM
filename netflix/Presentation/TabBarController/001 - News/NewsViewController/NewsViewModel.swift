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
    
    private var mediaLoadTask: Cancellable? {
        willSet { mediaLoadTask?.cancel() }
    }
    let items: Observable<[NewsTableViewCellViewModel]> = Observable([])
    var isEmpty: Bool { return items.value.isEmpty }
    
    init() {
        let dataTransferService = Application.app.services.dataTransfer
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
        mediaLoadTask = useCase.execute { [weak self] result in
            if case let .success(responseDTO) = result {
                self?.items.value = responseDTO.toCellViewModels()
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        }
    }
}

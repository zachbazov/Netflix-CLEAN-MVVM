//
//  NewsViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

final class NewsViewModel: ViewModel {
    var coordinator: NewsViewCoordinator?
    let useCase: NewsUseCase
    
    private var mediaLoadTask: Cancellable? { willSet { mediaLoadTask?.cancel() } }
    
    init() {
        let dataTransferService = Application.current.dataTransferService
        let cache = Application.current.mediaResponseCache
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService, cache: cache)
        self.useCase = NewsUseCase(mediaRepository: mediaRepository)
    }
    
    var items: Observable<[NewsTableViewCellViewModel]> = Observable([])
    
    func transform(input: Void) {}
}

extension NewsViewModel {
    func viewDidLoad() {
        fetchUpcomingMedia()
    }
    
    private func fetchUpcomingMedia() {
        mediaLoadTask = useCase.fetchUpcomingMedia { [weak self] result in
            if case let .success(responseDTO) = result {
                self?.items.value = responseDTO.toCellViewModels()
            } else if case let .failure(error) = result {
                print(2, error)
            }
        }
    }
}

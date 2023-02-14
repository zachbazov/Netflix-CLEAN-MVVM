//
//  SearchViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

// MARK: - SearchViewModel Type

final class SearchViewModel {
    var coordinator: SearchViewCoordinator?
    
    private lazy var repository: MediaRepository = createMediaRepository()
    private lazy var router = Router<MediaRepository>(repository: repository)
    
    private func createMediaRepository() -> MediaRepository {
        let dataTransferService = Application.app.services.dataTransfer
        return MediaRepository(dataTransferService: dataTransferService)
    }
    
    let items: Observable<[SearchCollectionViewCellViewModel]> = Observable([])
    let loading: Observable<SearchLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    private let error: Observable<String> = Observable("")
    private var isEmpty: Bool { return items.value.isEmpty }
}

// MARK: - ViewModel Implementation

extension SearchViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - Methods

extension SearchViewModel {
    private func set(media: [Media]) {
        items.value = media.map(SearchCollectionViewCellViewModel.init)
    }
    
    private func reset() {
        items.value.removeAll()
    }
    
    private func load(requestDTO: SearchHTTPDTO.Request, loading: SearchLoading) {
        self.loading.value = loading
        query.value = requestDTO.regex
        
        repository.task = router.request(
            for: [Media].self,
            request: requestDTO,
            cached: { media in
                // TBI
            },
            completion: { result in
                if case let .success(media) = result {
                    self.set(media: media)
                } else if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
                self.loading.value = .none
            })
    }
    
    private func update(requestDTO: SearchHTTPDTO.Request) {
        reset()
        load(requestDTO: requestDTO, loading: .fullscreen)
    }
}

// MARK: - UI Setup

extension SearchViewModel {
    func viewDidLoad() {}
    
    func didLoadNextPage(requestDTO: SearchHTTPDTO.Request) {
        load(requestDTO: requestDTO, loading: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        let requestDTO = SearchHTTPDTO.Request(regex: query)
        update(requestDTO: requestDTO)
    }
    
    func didCancelSearch() {
        repository.task?.cancel()
    }
}

// MARK: - SearchLoading Type

enum SearchLoading {
    case fullscreen
    case nextPage
}

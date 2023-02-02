//
//  SearchViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

// MARK: - SearchViewModel Type

final class SearchViewModel {
    
    // MARK: ViewModel's Properties
    
    var coordinator: SearchViewCoordinator?
    
    // MARK: Type's Properties
    
    private let useCase: SearchUseCase
    let items: Observable<[SearchCollectionViewCellViewModel]> = Observable([])
    let loading: Observable<SearchLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    private let error: Observable<String> = Observable("")
    private var isEmpty: Bool { return items.value.isEmpty }
    
    private var mediaLoadTask: Cancellable? { willSet { mediaLoadTask?.cancel() } }
    
    // MARK: Initializer
    
    /// Default initializer.
    /// Allocate `useCase` property and it's dependencies.
    init() {
        let dataTransferService = Application.current.dataTransferService
//        let mediaResponseCache = Application.current.mediaResponseCache
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService)
        self.useCase = SearchUseCase(mediaRepository: mediaRepository)
    }
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
        
        mediaLoadTask = useCase.execute(
            requestDTO: requestDTO,
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
        mediaLoadTask?.cancel()
    }
}

// MARK: - SearchLoading Type

enum SearchLoading {
    case fullscreen
    case nextPage
}

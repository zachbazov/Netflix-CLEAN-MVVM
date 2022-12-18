//
//  SearchViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

final class SearchViewModel: ViewModel {
    var coordinator: SearchViewCoordinator?
    
    let title = NSLocalizedString("SearchViewModel.Search", comment: "Search")
    var useCase: SearchUseCase
    
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    var pages: [MediaPage] = []
    var mediaLoadTask: Cancellable? {
        willSet { mediaLoadTask?.cancel() }
    }
    
    let items: Observable<[CollectionViewCellViewModel]> = Observable([])
    let loading: Observable<SearchLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    
    init() {
        let dataTransferService = Application.current.dataTransferService
        let mediaResponseCache = Application.current.mediaResponseCache
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService, cache: mediaResponseCache)
        self.useCase = SearchUseCase(mediaRepository: mediaRepository)
    }
    
    func transform(input: Void) {}
}

extension SearchViewModel {
    private func appendPage(_ mediaPage: MediaPage) {
        currentPage = mediaPage.page
        totalPageCount = mediaPage.totalPages
        
        pages = pages.filter { $0.page != mediaPage.page } + [mediaPage]
        
        items.value = pages.media.map(CollectionViewCellViewModel.init)
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func load(mediaQuery: MediaQuery, loading: SearchLoading) {
        self.loading.value = loading
        query.value = mediaQuery.query
        
        mediaLoadTask = useCase.execute(
            requestValue: SearchUseCaseRequestValue(query: mediaQuery, page: nextPage),
            cached: appendPage,
            completion: { result in
                if case let .success(page) = result {
                    self.appendPage(page)
                } else if case let .failure(error) = result {
                    print(error)
                }
                self.loading.value = .none
            })
    }
    
    private func update(mediaQuery: MediaQuery) {
        resetPages()
        load(mediaQuery: mediaQuery, loading: .fullscreen)
    }
}

extension SearchViewModel {
    func viewDidLoad() {}
    
    func didLoadNextPage() {
        guard hasMorePages, loading.value == .none else { return }
        load(mediaQuery: MediaQuery(query: query.value), loading: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(mediaQuery: MediaQuery(query: query))
    }
    
    func didCancelSearch() {
        mediaLoadTask?.cancel()
    }
}

private extension Array where Element == MediaPage {
    var media: [Media] { flatMap { $0.media } }
}

enum SearchLoading {
    case fullscreen
    case nextPage
}
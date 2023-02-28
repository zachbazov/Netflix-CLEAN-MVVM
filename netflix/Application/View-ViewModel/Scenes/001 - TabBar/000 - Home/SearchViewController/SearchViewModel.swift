//
//  SearchViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func set(media: [Media])
    func load(requestDTO: SearchHTTPDTO.Request, loading: SearchLoading)
    func update(requestDTO: SearchHTTPDTO.Request)
    
    func didLoadNextPage(requestDTO: SearchHTTPDTO.Request)
    func didSearch(query: String)
}

private protocol ViewModelOutput {
    var useCase: MediaUseCase { get }
    
    var items: Observable<[SearchCollectionViewCellViewModel]> { get }
    var loading: Observable<SearchLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    
    func reset()
    
    func didCancelSearch()
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - SearchViewModel Type

final class SearchViewModel {
    var coordinator: SearchViewCoordinator?
    
    fileprivate let useCase = MediaUseCase()
    
    let items: Observable<[SearchCollectionViewCellViewModel]> = Observable([])
    let loading: Observable<SearchLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    fileprivate let error: Observable<String> = Observable("")
    fileprivate var isEmpty: Bool { return items.value.isEmpty }
}

// MARK: - ViewModel Implementation

extension SearchViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SearchViewModel: ViewModelProtocol {
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
        useCase.repository.task?.cancel()
    }
    
    fileprivate func set(media: [Media]) {
        items.value = media.map(SearchCollectionViewCellViewModel.init)
    }
    
    fileprivate func reset() {
        items.value.removeAll()
    }
    
    fileprivate func load(requestDTO: SearchHTTPDTO.Request, loading: SearchLoading) {
        self.loading.value = loading
        query.value = requestDTO.regex
        
        useCase.repository.task = useCase.request(
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
    
    fileprivate func update(requestDTO: SearchHTTPDTO.Request) {
        reset()
        load(requestDTO: requestDTO, loading: .fullscreen)
    }
}

// MARK: - SearchLoading Type

enum SearchLoading {
    case fullscreen
    case nextPage
}

//
//  SearchViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var useCase: MediaUseCase { get }
    
    var items: Observable<[SearchCollectionViewCellViewModel]> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var topSearches: [Media] { get }
    
    func willSearch(for query: String)
    func willCancelSearch()
    func itemsWillChange(mapping media: [Media])
    func itemsWillRemove()
    func queryWillChange(_ query: String)
    func searchWillLoad(_ request: SearchHTTPDTO.Request)
}

// MARK: - SearchViewModel Type

final class SearchViewModel {
    var coordinator: SearchViewCoordinator?
    
    fileprivate let useCase = MediaUseCase()
    
    let items: Observable<[SearchCollectionViewCellViewModel]> = Observable([])
    
    let query: Observable<String> = Observable("")
    
    fileprivate let error: Observable<String> = Observable("")
    
    fileprivate var isEmpty: Bool { return items.value.isEmpty }
    
    var topSearches: [Media] {
        guard let controller = Application.app.coordinator.tabCoordinator.viewController?.homeViewController else { fatalError("Unexpected controller \(HomeViewController.self) value.") }
        
        return controller.viewModel.topSearches
    }
}

// MARK: - ViewModel Implementation

extension SearchViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SearchViewModel: ViewModelProtocol {
    func willSearch(for query: String) {
        guard !query.isEmpty else { return }
        
        let requestDTO = SearchHTTPDTO.Request(regex: query)
        
        queryWillChange(query)
        itemsWillRemove()
        searchWillLoad(requestDTO)
    }
    
    func willCancelSearch() {
        useCase.repository.task?.cancel()
    }
    
    func itemsWillChange(mapping media: [Media]) {
        items.value = media.map(SearchCollectionViewCellViewModel.init)
    }
    
    fileprivate func itemsWillRemove() {
        items.value.removeAll()
    }
    
    fileprivate func queryWillChange(_ query: String) {
        self.query.value = query
    }
    
    fileprivate func searchWillLoad(_ request: SearchHTTPDTO.Request) {
        coordinator?.viewController?.textFieldIndicatorView?.isLoading = true
        
        useCase.repository.task = useCase.request(
            endpoint: .searchMedia,
            for: SearchHTTPDTO.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    let media = response.data.toDomain()
                    
                    self.itemsWillChange(mapping: media)
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
                
                self.coordinator?.viewController?.textFieldIndicatorView?.isLoading = false
            })
    }
}

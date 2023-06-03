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
}

// MARK: - SearchViewModel Type

final class SearchViewModel {
    var coordinator: SearchViewCoordinator?
    
    fileprivate lazy var useCase: MediaUseCase = createUseCase()
    
    let items: Observable<[SearchCollectionViewCellViewModel]> = Observable([])
    
    let query: Observable<String> = Observable("")
    
    fileprivate let error: Observable<String> = Observable("")
    
    fileprivate var isEmpty: Bool { return items.value.isEmpty }
    
    var topSearches: [Media] {
        guard let controller = Application.app.coordinator.tabCoordinator?.home?.viewControllers.first as? HomeViewController else {
            fatalError("Unexpected controller \(HomeViewController.self) value.")
        }
        
        return controller.viewModel.topSearches
    }
    
    var isLoading: Bool = false {
        didSet {
            coordinator?.viewController?.textFieldIndicatorView?.isLoading = isLoading
        }
    }
}

// MARK: - ViewModel Implementation

extension SearchViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SearchViewModel: ViewModelProtocol {
    func willSearch(for query: String) {
        guard !query.isEmpty else { return }
        
        queryWillChange(query)
        itemsWillRemove()
        
        loadSearch()
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
}

// MARK: - Private Implementation

extension SearchViewModel {
    private func loadSearch() {
        if #available(iOS 13.0, *) {
            loadUsingAsyncAwait()
            
            return
        }
        
        loadUsingAsync()
    }
    
    private func loadUsingAsyncAwait() {
        Task {
            await searchWillLoad()
        }
    }
    
    private func loadUsingAsync() {
        let request = SearchHTTPDTO.Request(regex: query.value)
        
        searchWillLoad(request)
    }
    
    private func searchWillLoad(_ request: SearchHTTPDTO.Request) {
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
    
    private func searchWillLoad() async {
        mainQueueDispatch { [weak self] in
            self?.isLoading = true
        }
        
        let request = SearchHTTPDTO.Request(regex: query.value)
        let response = await useCase.request(endpoint: .searchMedia, for: SearchHTTPDTO.Response.self, request: request)
        
        guard let response = response else { return }
        
        let media = response.data.toDomain()
        itemsWillChange(mapping: media)
        
        mainQueueDispatch { [weak self] in
            self?.isLoading = false
        }
    }
}

// MARK: - Private Implementation

extension SearchViewModel {
    private func createUseCase() -> MediaUseCase {
        let services = Application.app.services
        let stores = Application.app.stores
        let dataTransferService = services.dataTransfer
        let persistentStore = stores.mediaResponses
        let repository = MediaRepository(dataTransferService: dataTransferService, persistentStore: persistentStore)
        return MediaUseCase(repository: repository)
    }
}

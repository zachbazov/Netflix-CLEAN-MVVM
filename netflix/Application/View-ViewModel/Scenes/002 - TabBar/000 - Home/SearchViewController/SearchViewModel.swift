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
    func load(requestDTO: SearchHTTPDTO.Request)
    func update(requestDTO: SearchHTTPDTO.Request)
    
    func didLoadNextPage(requestDTO: SearchHTTPDTO.Request)
    func didSearch(query: String)
}

private protocol ViewModelOutput {
    var useCase: MediaUseCase { get }
    
    var items: Observable<[SearchCollectionViewCellViewModel]> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var topSearches: [Media] { get }
    
    func reset()
    func didCancelSearch()
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - SearchViewModel Type

final class SearchViewModel {
    var coordinator: SearchViewCoordinator?
    
    fileprivate let useCase = MediaUseCase()
    
    let items: Observable<[SearchCollectionViewCellViewModel]> = Observable([])
    let query: Observable<String> = Observable("")
    fileprivate let error: Observable<String> = Observable("")
    fileprivate var isEmpty: Bool { return items.value.isEmpty }
    var topSearches: [Media] {
        let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as! HomeViewController
        return homeViewController.viewModel.topSearches
    }
}

// MARK: - ViewModel Implementation

extension SearchViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SearchViewModel: ViewModelProtocol {
    func viewDidLoad() {}
    
    func didLoadNextPage(requestDTO: SearchHTTPDTO.Request) {
        load(requestDTO: requestDTO)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        let requestDTO = SearchHTTPDTO.Request(regex: query)
        self.query.value = query
        update(requestDTO: requestDTO)
    }
    
    func didCancelSearch() {
        useCase.repository.task?.cancel()
    }
    
    func set(media: [Media]) {
        items.value = media.map(SearchCollectionViewCellViewModel.init)
    }
    
    fileprivate func reset() {
        items.value.removeAll()
    }
    
    fileprivate func load(requestDTO: SearchHTTPDTO.Request) {
        coordinator?.viewController?.textFieldIndicatorView?.isLoading = true
        
        useCase.repository.task = useCase.request(
            endpoint: .searchMedia,
            for: SearchHTTPDTO.Response.self,
            request: requestDTO,
            cached: { _ in },
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    let media = responseDTO.data.toDomain()
                    self?.set(media: media)
                } else if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
                self?.coordinator?.viewController?.textFieldIndicatorView?.isLoading = false
            })
    }
    
    fileprivate func update(requestDTO: SearchHTTPDTO.Request) {
        reset()
        load(requestDTO: requestDTO)
    }
}

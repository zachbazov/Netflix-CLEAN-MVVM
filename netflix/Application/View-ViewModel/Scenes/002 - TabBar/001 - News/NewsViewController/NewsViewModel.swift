//
//  NewsViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var useCase: MediaUseCase { get }
    
    var items: Observable<[NewsCollectionViewCellViewModel]> { get }
    
    var isEmpty: Bool { get }
    
    var section: Section? { get }
    var media: Media? { get }
    var shouldScreenRotate: Bool { get }
}

// MARK: - NewsViewModel Type

final class NewsViewModel {
    var coordinator: NewsViewCoordinator?
    
    fileprivate let useCase = MediaUseCase()
    
    let items: Observable<[NewsCollectionViewCellViewModel]> = Observable([])
    
    var isEmpty: Bool { return items.value.isEmpty }
    
    var section: Section?
    var media: Media?
    var shouldScreenRotate: Bool = false
}

// MARK: - ViewModel Implementaiton

extension NewsViewModel: ViewModel {
    func viewDidLoad() {
        loadUpcomings()
    }
}

// MARK: - ViewModelProtocol Implementation

extension NewsViewModel: ViewModelProtocol {}

// MARK: - Private Implementation

extension NewsViewModel {
    private func loadUsingAsync() {
        upcomingMediaWillLoad()
    }
    
    private func loadUsingAsyncAwait() {
        Task {
            await upcomingMediaWillLoad()
        }
    }
    
    private func loadUpcomings() {
        if #available(iOS 13.0, *) {
            return loadUsingAsyncAwait()
        }
        
        loadUsingAsync()
    }
    
    private func upcomingMediaWillLoad() {
        useCase.repository.task = useCase.request(
            endpoint: .getUpcomings,
            for: NewsHTTPDTO.Response.self,
            request: Any.self,
            cached: nil,
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.items.value = response.toCellViewModels()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    private func upcomingMediaWillLoad() async {
        let response = await useCase.request(endpoint: .getUpcomings, for: NewsHTTPDTO.Response.self)
        
        guard let response = response else { return }
        
        items.value = response.toCellViewModels()
    }
}

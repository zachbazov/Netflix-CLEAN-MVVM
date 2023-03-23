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
    
    func viewDidLoad()
    func fetchUpcomingMedia()
}

// MARK: - NewsViewModel Type

final class NewsViewModel {
    var coordinator: NewsViewCoordinator?
    
    fileprivate let useCase = MediaUseCase()
    
    let items: Observable<[NewsCollectionViewCellViewModel]> = Observable([])
    var isEmpty: Bool { return items.value.isEmpty }
}

// MARK: - ViewModel Implementaiton

extension NewsViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension NewsViewModel: ViewModelProtocol {
    func viewDidLoad() {
        fetchUpcomingMedia()
    }
    
    fileprivate func fetchUpcomingMedia() {
        useCase.repository.task = useCase.request(
            endpoint: .getUpcomings,
            for: NewsHTTPDTO.Response.self,
            request: Any.self,
            cached: nil,
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    self?.items.value = responseDTO.toCellViewModels()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
            })
    }
}

//
//  DetailCollectionViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var season: Observable<Season> { get }
    var state: Observable<DetailCollectionView.State> { get }
    
    func stateWillChange(_ state: DetailCollectionView.State)
    func seasonWillChange(_ season: Season)
    
    func seasonDidLoad(request: SeasonHTTPDTO.Request, _ completion: @escaping () -> Void)
}

// MARK: - DetailCollectionViewModel Type

final class DetailCollectionViewModel {
    let coordinator: DetailViewCoordinator
    
    let season: Observable<Season> = Observable(.vacantValue)
    let state: Observable<DetailCollectionView.State> = Observable(.series)
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
    }
}

// MARK: - ViewModel Implementation

extension DetailCollectionViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailCollectionViewModel: ViewModelProtocol {
    func seasonWillChange(_ season: Season) {
        self.season.value = season
    }
    
    func stateWillChange(_ state: DetailCollectionView.State) {
        self.state.value = state
    }
    
    func seasonDidLoad(request: SeasonHTTPDTO.Request, _ completion: @escaping () -> Void) {
        guard let useCase = coordinator.viewController?.viewModel.useCase else { return }
        
        useCase.repository.task = useCase.request(
            endpoint: .getSeason,
            for: SeasonHTTPDTO.Response.self,
            request: request,
            cached: nil,
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    guard var season = responseDTO.data.first else { return }
                    
                    season.episodes = season.episodes.sorted { $0.episode < $1.episode }
                    
                    self?.season.value = season.toDomain()
                    
                    completion()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func seasonDidLoad() async {}
}

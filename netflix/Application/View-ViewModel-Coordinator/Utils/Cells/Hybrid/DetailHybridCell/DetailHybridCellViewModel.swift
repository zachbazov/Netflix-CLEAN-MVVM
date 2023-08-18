//
//  DetailHybridCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 25/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var season: Observable<Season> { get }
    var state: Observable<DetailHybridCell.State> { get }
    var media: Media { get }
    var section: Section { get }
    
    func stateWillChange(_ state: DetailHybridCell.State)
    func seasonWillChange(_ season: Season)
    
    func setItems(for state: DetailNavigationView.State) -> [MediaRepresentable]
}

// MARK: - DetailHybridCellViewModel Type

final class DetailHybridCellViewModel {
    let coordinator: DetailViewCoordinator
    
    let season: Observable<Season> = Observable(.vacantValue)
    let state: Observable<DetailHybridCell.State> = Observable(.series)
    
    let media: Media
    let section: Section
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        guard let media = viewModel.media,
              let section = viewModel.section
        else { fatalError() }
        self.media = media
        self.section = section
    }
}

// MARK: - ViewModel Implementation

extension DetailHybridCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailHybridCellViewModel: ViewModelProtocol {
    func seasonWillChange(_ season: Season) {
        self.season.value = season
    }
    
    func stateWillChange(_ state: DetailHybridCell.State) {
        self.state.value = state
    }
    
    func setItems(for state: DetailNavigationView.State) -> [MediaRepresentable] {
        switch state {
        case .episodes:
            return season.value.episodes
        case .trailers:
            return media.resources.trailers.toDomain()
        case .similarContent:
            return section.media
        }
    }
}

// MARK: - Private Implementation

extension DetailHybridCellViewModel {
    func fetchEpisodes() {
        guard let controller = coordinator.viewController,
              let dataSource = controller.dataSource,
              let state = dataSource.navigationCell?.navigationView?.viewModel.state.value
        else { return }
        
        if case .episodes = state {
            let cellViewModel = DetailCollectionViewCellViewModel(with: controller.viewModel)
            let requestDTO = SeasonHTTPDTO.Request(slug: cellViewModel.slug, season: 1)
            
            self.seasonDidLoad(request: requestDTO) { _ in }
        }
    }
    
    private func seasonDidLoad(request: SeasonHTTPDTO.Request, _ completion: @escaping (Season) -> Void) {
        guard let useCase = coordinator.viewController?.viewModel.useCase else { return }
        
        useCase.repository.task = useCase.request(
            endpoint: .getSeason,
            for: SeasonHTTPDTO.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    guard var season = responseDTO.data.first else { return }
                    
                    season.episodes = season.episodes.sorted { $0.episode < $1.episode }
                    
                    self?.season.value = season.toDomain()
                    
                    completion(season.toDomain())
                    printIfDebug(.debug, "success season fetching eps \(season.toDomain().episodes.count)")
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
            })
    }
}

//
//  DetailNavigationViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media { get }
    var state: Observable<DetailNavigationView.State> { get }
}

// MARK: - DetailNavigationViewModel Type

final class DetailNavigationViewModel {
    let coordinator: DetailViewCoordinator
    
    let media: Media
    let state: Observable<DetailNavigationView.State> = Observable(.episodes)
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        guard let media = viewModel.media else { fatalError() }
        
        self.media = media
    }
}

// MARK: - ViewModel Implementation

extension DetailNavigationViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailNavigationViewModel: ViewModelProtocol {
    func stateWillChange(_ state: DetailNavigationView.State) {
        self.state.value = state
    }
}

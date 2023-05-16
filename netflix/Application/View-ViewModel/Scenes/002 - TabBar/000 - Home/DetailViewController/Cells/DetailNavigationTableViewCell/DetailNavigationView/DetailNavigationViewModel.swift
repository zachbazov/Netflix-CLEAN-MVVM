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
    var state: DetailNavigationView.State { get }
}

// MARK: - DetailNavigationViewModel Type

final class DetailNavigationViewModel {
    let coordinator: DetailViewCoordinator
    
    let media: Media
    var state: DetailNavigationView.State
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        guard let media = viewModel.media else { fatalError() }
        
        self.media = media
        
        self.state = viewModel.navigationViewState.value
    }
}

// MARK: - ViewModel Implementation

extension DetailNavigationViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailNavigationViewModel: ViewModelProtocol {
    func stateWillChange(_ state: DetailNavigationView.State) {
        guard let viewModel = coordinator.viewController?.viewModel else { return }
        
        viewModel.navigationViewState.value = state
    }
}

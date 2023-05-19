//
//  ShowcaseTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 21/11/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media { get }
}

// MARK: - ShowcaseTableViewCellViewModel Type

struct ShowcaseTableViewCellViewModel {
    let coordinator: HomeViewCoordinator
    
    let media: Media
    
    /// Create a display table view cell view model.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else {
            fatalError("Unexpected coordinator \(HomeViewCoordinator.self) value.")
        }
        self.coordinator = coordinator
        
        let media = viewModel.showcases[viewModel.dataSourceState.value] ?? .vacantValue
        self.media = media
    }
}

// MARK: - ViewModel Implementation

extension ShowcaseTableViewCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension ShowcaseTableViewCellViewModel: ViewModelProtocol {}

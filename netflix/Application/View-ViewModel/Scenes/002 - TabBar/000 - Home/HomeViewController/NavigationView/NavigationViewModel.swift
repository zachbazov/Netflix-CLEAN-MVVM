//
//  NavigationViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    
}

// MARK: - NavigationViewModel Type

struct NavigationViewModel {
    let coordinator: HomeViewCoordinator
    
    init?(with viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else { return nil }
        self.coordinator = coordinator
    }
}

// MARK: - ViewModel Implementation

extension NavigationViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension NavigationViewModel: ViewModelProtocol {}

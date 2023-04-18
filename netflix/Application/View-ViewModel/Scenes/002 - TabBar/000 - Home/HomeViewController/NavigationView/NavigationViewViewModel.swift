//
//  NavigationViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 18/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var state: Observable<NavigationView.State?> { get }
    
    func stateDidChange(_ state: NavigationView.State)
}

// MARK: - NavigationViewViewModel Type

final class NavigationViewViewModel {
    let coordinator: HomeViewCoordinator
    
    let state: Observable<NavigationView.State?> = Observable(.none)
    
    /// Create a navigation view view model object.
    /// - Parameters:
    ///   - items: Represented items on the navigation.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension NavigationViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension NavigationViewViewModel: ViewModelProtocol {
    /// Controls the navigation presentation of items.
    /// - Parameter state: Corresponding state.
    func stateDidChange(_ state: NavigationView.State) {
        switch state {
        case .airPlay:
            guard let controller = coordinator.viewController else { return }
            controller.navigationView?.airPlayButton.asRoutePickerView()
        case .search:
            coordinator.coordinate(to: .search)
        case .account:
            coordinator.coordinate(to: .account)
        }
        
        self.state.value = state
    }
}

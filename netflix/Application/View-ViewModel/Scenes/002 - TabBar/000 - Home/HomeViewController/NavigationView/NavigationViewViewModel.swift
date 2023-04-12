//
//  NavigationViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 18/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var items: [NavigationViewItem] { get }
    var state: Observable<NavigationView.State> { get }
    
    func stateDidChange(_ state: NavigationView.State)
}

// MARK: - NavigationViewViewModel Type

final class NavigationViewViewModel {
    let coordinator: HomeViewCoordinator
    
    fileprivate let items: [NavigationViewItem]
    let state: Observable<NavigationView.State> = Observable(.home)
    
    /// Create a navigation view view model object.
    /// - Parameters:
    ///   - items: Represented items on the navigation.
    ///   - viewModel: Coordinating view model.
    init(items: [NavigationViewItem], with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.items = items
    }
}

// MARK: - ViewModel Implementation

extension NavigationViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension NavigationViewViewModel: ViewModelProtocol {
    /// Controls the navigation presentation of items.
    /// - Parameter state: Corresponding state.
    func stateDidChange(_ state: NavigationView.State) {
        guard let controller = coordinator.viewController else { return }
        
        switch state {
        case .home:
            controller.segmentControlView?.tvShowsItemViewContainer.isHidden(false)
            controller.segmentControlView?.moviesItemViewContainer.isHidden(false)
            controller.segmentControlView?.categoriesItemViewContainer.isHidden(false)
            controller.segmentControlView?.itemsCenterXConstraint.constant = .zero
        case .airPlay:
            break
        case .search:
            coordinator.coordinate(to: .search)
        case .account:
            coordinator.coordinate(to: .account)
        case .tvShows:
            controller.segmentControlView?.tvShowsItemViewContainer.isHidden(false)
            controller.segmentControlView?.moviesItemViewContainer.isHidden(true)
            controller.segmentControlView?.categoriesItemViewContainer.isHidden(false)
            controller.segmentControlView?.itemsCenterXConstraint.constant = -24.0
        case .movies:
            controller.segmentControlView?.tvShowsItemViewContainer.isHidden(true)
            controller.segmentControlView?.moviesItemViewContainer.isHidden(false)
            controller.segmentControlView?.categoriesItemViewContainer.isHidden(false)
            controller.segmentControlView?.itemsCenterXConstraint.constant = -32.0
        case .categories:
            break
        }
        
        controller.segmentControlView?.animateUsingSpring(withDuration: 0.33,
                                                          withDamping: 0.7,
                                                          initialSpringVelocity: 0.7)
    }
}

//
//  SegmentControlViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 17/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var items: [NavigationViewItem] { get }
    var state: Observable<NavigationView.State> { get }
    
    func stateDidChange(_ state: NavigationView.State)
}

// MARK: - SegmentControlViewViewModel Type

final class SegmentControlViewViewModel {
    private let coordinator: HomeViewCoordinator
    
    fileprivate let items: [NavigationViewItem]
    let state: Observable<NavigationView.State> = Observable(.tvShows)
    
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

extension SegmentControlViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SegmentControlViewViewModel: ViewModelProtocol {
    /// Controls the navigation presentation of items.
    /// - Parameter state: Corresponding state.
    func stateDidChange(_ state: NavigationView.State) {
        guard let segmentView = coordinator.viewController?.segmentControlView else { return }
        
        switch state {
        case .home:
            segmentView.tvShowsItemViewContainer.isHidden(false)
            segmentView.moviesItemViewContainer.isHidden(false)
            segmentView.categoriesItemViewContainer.isHidden(false)
            segmentView.itemsCenterXConstraint.constant = .zero
        case .airPlay:
            break
        case .search:
            coordinator.coordinate(to: .search)
        case .account:
            coordinator.coordinate(to: .account)
        case .tvShows:
            segmentView.tvShowsItemViewContainer.isHidden(false)
            segmentView.moviesItemViewContainer.isHidden(true)
            segmentView.categoriesItemViewContainer.isHidden(false)
            segmentView.itemsCenterXConstraint.constant = -24.0
        case .movies:
            segmentView.tvShowsItemViewContainer.isHidden(true)
            segmentView.moviesItemViewContainer.isHidden(false)
            segmentView.categoriesItemViewContainer.isHidden(false)
            segmentView.itemsCenterXConstraint.constant = -32.0
        case .categories:
            break
        }
        
        segmentView.animateUsingSpring(withDuration: 0.33,
                                          withDamping: 0.7,
                                          initialSpringVelocity: 0.7)
    }
}

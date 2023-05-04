//
//  SegmentControlViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 17/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var state: Observable<SegmentControlView.State> { get }
    var segment: Observable<SegmentControlView.State> { get }
    
    var isSegmentSelected: Bool { get }
    
    func stateWillChange(_ state: SegmentControlView.State)
    func stateDidChange(_ state: SegmentControlView.State)
    func segmentDidChange(_ segment: SegmentControlView.State)
    func stateDidDefault()
}

// MARK: - SegmentControlViewViewModel Type

final class SegmentControlViewViewModel {
    let coordinator: HomeViewCoordinator
    
    let state: Observable<SegmentControlView.State> = Observable(.main)
    let segment: Observable<SegmentControlView.State> = Observable(.main)
    
    var isSegmentSelected = false
    
    /// Create a navigation view view model object.
    /// - Parameters:
    ///   - items: Represented items on the navigation.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension SegmentControlViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SegmentControlViewViewModel: ViewModelProtocol {
    func stateWillChange(_ state: SegmentControlView.State) {
        self.state.value = state
    }
    
    func stateDidChange(_ state: SegmentControlView.State) {
        guard let controller = coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let segmentControl = controller.segmentControlView,
              let navigationOverlay = controller.navigationOverlayView,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        guard let section = navigationOverlay.viewModel?.category.toSection() else { return }
        
        switch state {
        case .main:
            isSegmentSelected = false
            
            homeViewModel.dataSourceState.value = .all
            
            navigationOverlay.viewModel?.stateWillChange(.main)
            
            segmentWillChange(state)
            
            browseOverlay.viewModel?.isPresented.value = false
            
            controller.dataSource?.style.addGradient()
        case .all:
            segmentControl.presentNavigationOverlayIfNeeded()
            
            isSegmentSelected = true
            
            guard homeViewModel.dataSourceState.value != .all else { return }
            
            homeViewModel.dataSourceState.value = .all
            
            segmentWillChange(state)
            
            browseOverlay.viewModel?.section.value = section
        case .tvShows:
            segmentControl.presentNavigationOverlayIfNeeded()
            
            isSegmentSelected = true
            
            guard homeViewModel.dataSourceState.value != .tvShows else { return }
            
            homeViewModel.dataSourceState.value = .tvShows
            
            segmentWillChange(state)
            
            browseOverlay.viewModel?.section.value = section
        case .movies:
            segmentControl.presentNavigationOverlayIfNeeded()
            
            isSegmentSelected = true
            
            guard homeViewModel.dataSourceState.value != .movies else { return }
            
            homeViewModel.dataSourceState.value = .movies
            
            segmentWillChange(state)
            
            browseOverlay.viewModel?.section.value = section
        case .categories:
            navigationOverlay.viewModel?.isPresented.value = true
            navigationOverlay.viewModel?.state.value = .genres
        }
    }
    
    func segmentWillChange(_ segment: SegmentControlView.State) {
        self.segment.value = segment
    }
    
    func segmentDidChange(_ segment: SegmentControlView.State) {
        switch segment {
        case .main:
            stateDidDefault()
        default:
            self.segment.value = segment
            isSegmentSelected = false
            state.value = segment
        }
    }
    
    /// Based on the `state` value, configures the selection of segments to prevent any inappropriate behaviors.
    /// Since the view initiates with `state` and `segment` values set to `.main`.
    /// This particular state creates an inconsistency with the `navigationOverlay` segments variation.
    /// Once the `state` value set to `.all, .tvShows` or `.movies`
    /// the selection of the `.main` state would restore the view to its default state.
    /// Once the `state` value set to `.categories` which represents the default case in this function,
    /// the selection of any category on the `navigationOverlay`
    /// without changing the `.main` state would be stated as `.all`.
    fileprivate func stateDidDefault() {
        switch state.value {
        case .all, .tvShows, .movies:
            segment.value = .main
            isSegmentSelected = false
            state.value = .main
        default:
            segment.value = .all
            isSegmentSelected = false
            state.value = .all
        }
    }
}

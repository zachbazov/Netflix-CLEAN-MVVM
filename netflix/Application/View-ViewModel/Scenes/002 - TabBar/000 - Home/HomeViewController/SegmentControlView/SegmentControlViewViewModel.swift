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
    var segment: SegmentControlView.State { get }
    
    var isSegmentSelected: Bool { get }
    
    func stateWillChange(_ state: SegmentControlView.State)
    func stateDidChange(_ state: SegmentControlView.State)
    func stateDidDefault()
    func setSegment(_ segment: SegmentControlView.State)
    func segmentDidChange(_ segment: SegmentControlView.State)
}

// MARK: - SegmentControlViewViewModel Type

final class SegmentControlViewViewModel {
    let coordinator: HomeViewCoordinator
    
    let state: Observable<SegmentControlView.State> = Observable(.main)
    
    var segment: SegmentControlView.State = .main
    
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
              let segmentControl = controller.segmentControl,
              let navigationOverlay = controller.navigationOverlay,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        guard let section = navigationOverlay.viewModel?.category.toSection() else { return }
        
        switch state {
        case .main:
            isSegmentSelected = false
            setSegment(state)
            
            homeViewModel.dataSourceStateWillChange(.all)
            navigationOverlay.viewModel?.stateWillChange(.main)
            browseOverlay.viewModel?.isPresentedWillChange(false)
            controller.dataSource?.style.addGradient()
        case .all:
            segmentControl.presentNavigationOverlayIfNeeded()
            
            isSegmentSelected = true
            setSegment(state)
            
            homeViewModel.changeDataSourceStateIfNeeded(.all)
            browseOverlay.viewModel?.sectionWillChange(section)
        case .tvShows:
            segmentControl.presentNavigationOverlayIfNeeded()
            
            isSegmentSelected = true
            setSegment(state)
            
            homeViewModel.changeDataSourceStateIfNeeded(.tvShows)
            browseOverlay.viewModel?.sectionWillChange(section)
        case .movies:
            segmentControl.presentNavigationOverlayIfNeeded()
            
            isSegmentSelected = true
            setSegment(state)
            
            homeViewModel.changeDataSourceStateIfNeeded(.movies)
            browseOverlay.viewModel?.sectionWillChange(section)
        case .categories:
            navigationOverlay.viewModel?.isPresentedWillChange(true)
            navigationOverlay.viewModel?.stateWillChange(.genres)
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
            segment = .main
            isSegmentSelected = false
            state.value = .main
        default:
            segment = .all
            isSegmentSelected = false
            state.value = .all
        }
    }
    
    func setSegment(_ segment: SegmentControlView.State) {
        self.segment = segment
    }
    
    func segmentDidChange(_ segment: SegmentControlView.State) {
        switch segment {
        case .main:
            stateDidDefault()
        default:
            self.segment = segment
            isSegmentSelected = false
            state.value = segment
        }
    }
}

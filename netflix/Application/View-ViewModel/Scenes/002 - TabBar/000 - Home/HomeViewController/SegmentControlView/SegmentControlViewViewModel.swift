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
    
    func segmentDidChange(_ segment: SegmentControlView.State)
    func restoreDefaultStateIfNeeded()
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
    func segmentDidChange(_ segment: SegmentControlView.State) {
        switch segment {
        case .main:
            restoreDefaultStateIfNeeded()
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
    fileprivate func restoreDefaultStateIfNeeded() {
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

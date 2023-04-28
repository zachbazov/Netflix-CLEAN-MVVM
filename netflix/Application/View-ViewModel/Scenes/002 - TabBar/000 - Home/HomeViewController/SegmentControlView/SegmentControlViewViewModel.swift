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
}

// MARK: - SegmentControlViewViewModel Type

final class SegmentControlViewViewModel {
    let coordinator: HomeViewCoordinator
    
    let state: Observable<SegmentControlView.State> = Observable(.main)
    
    var hasTvExpanded = false
    var hasMoviesExpanded = false
    
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

extension SegmentControlViewViewModel: ViewModelProtocol {}

//
//  BrowseOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - BrowseOverlayViewModel Type

final class BrowseOverlayViewModel {
    
    // MARK: Properties
    
    private let coordinator: HomeViewCoordinator
    var isPresented = false {
        didSet { shouldDisplayOrHide() }
    }
    
    // MARK: Initializer
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - Methods

extension BrowseOverlayViewModel {
    private func shouldDisplayOrHide() {
        guard let homeViewController = coordinator.viewController else { return }
        
        if isPresented {
            homeViewController.browseOverlayViewContainer.isHidden(false)
            
            homeViewController.view.animateUsingSpring(
                withDuration: 0.5,
                withDamping: 1.0,
                initialSpringVelocity: 0.7,
                animations: {
                    homeViewController.navigationViewContainer.backgroundColor = .black
                    homeViewController.browseOverlayViewContainer.alpha = 1.0
                })
            
            return
        }
        
        homeViewController.view.animateUsingSpring(
            withDuration: 0.5,
            withDamping: 1.0,
            initialSpringVelocity: 0.7,
            animations: {
                homeViewController.navigationViewContainer.backgroundColor = .clear
                homeViewController.browseOverlayViewContainer.alpha = .zero
            }) { done in
                if done {
                    homeViewController.browseOverlayViewContainer.isHidden(true)
                }
            }
    }
}

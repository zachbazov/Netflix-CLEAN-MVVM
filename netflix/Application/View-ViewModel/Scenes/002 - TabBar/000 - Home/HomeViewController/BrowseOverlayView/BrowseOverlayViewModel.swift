//
//  BrowseOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var isPresented: Bool { get }
    
    func shouldDisplayOrHide()
}

// MARK: - BrowseOverlayViewModel Type

struct BrowseOverlayViewModel {
    private let coordinator: HomeViewCoordinator
    
    var isPresented = false {
        didSet { shouldDisplayOrHide() }
    }
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension BrowseOverlayViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension BrowseOverlayViewModel: ViewModelProtocol {
    fileprivate func shouldDisplayOrHide() {
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

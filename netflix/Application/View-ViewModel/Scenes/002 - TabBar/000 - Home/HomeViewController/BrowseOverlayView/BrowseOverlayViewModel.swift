//
//  BrowseOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var isPresented: Observable<Bool> { get }
    
    func shouldDisplayOrHide()
}

// MARK: - BrowseOverlayViewModel Type

struct BrowseOverlayViewModel {
    let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension BrowseOverlayViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension BrowseOverlayViewModel: ViewModelProtocol {
    func shouldDisplayOrHide() {
        guard let homeViewController = coordinator.viewController else { return }
        
        if isPresented.value {
            homeViewController.browseOverlayViewContainer.isHidden(false)
            
            homeViewController.view.animateUsingSpring(
                withDuration: 0.5,
                withDamping: 1.0,
                initialSpringVelocity: 0.7,
                animations: {
                    homeViewController.browseOverlayViewContainer.alpha = 1.0
                    homeViewController.browseOverlayViewContainer.transform = .identity
                })
            
            return
        }
        
        homeViewController.view.animateUsingSpring(
            withDuration: 0.5,
            withDamping: 1.0,
            initialSpringVelocity: 0.7,
            animations: {
                homeViewController.browseOverlayViewContainer.alpha = .zero
                homeViewController.browseOverlayViewContainer.transform = CGAffineTransform(translationX: .zero, y: homeViewController.browseOverlayViewContainer.bounds.height)
            }) { done in
                if done {
                    homeViewController.browseOverlayViewContainer.isHidden(true)
                }
            }
    }
}

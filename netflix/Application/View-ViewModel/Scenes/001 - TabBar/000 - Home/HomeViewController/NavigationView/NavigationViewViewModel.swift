//
//  NavigationViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 18/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func stateDidChange(_ state: NavigationView.State)
}

private protocol ViewModelOutput {
    var items: [NavigationViewItem] { get }
    var state: Observable<NavigationView.State> { get }
    
    func navigationViewDidAppear()
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - NavigationViewViewModel Type

final class NavigationViewViewModel {
    private let coordinator: HomeViewCoordinator
    
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
    /// Animate the first appearance of the navigation view.
    func navigationViewDidAppear() {
        let homeViewController = coordinator.viewController!
        mainQueueDispatch {
            homeViewController.navigationViewTopConstraint.constant = 0.0
            homeViewController.navigationView.alpha = 1.0
            homeViewController.view.animateUsingSpring(withDuration: 0.66,
                                                       withDamping: 1.0,
                                                       initialSpringVelocity: 1.0)
        }
    }
    /// Controls the navigation presentation of items.
    /// - Parameter state: Corresponding state.
    func stateDidChange(_ state: NavigationView.State) {
        let navigationView = coordinator.viewController!.navigationView!
        
        navigationView.categoriesItemView.viewDidConfigure(for: state)
        
        switch state {
        case .home:
            navigationView.tvShowsItemViewContainer.isHidden(false)
            navigationView.moviesItemViewContainer.isHidden(false)
            navigationView.categoriesItemViewContainer.isHidden(false)
            navigationView.itemsCenterXConstraint.constant = .zero
        case .airPlay:
            break
        case .search:
            coordinator.coordinate(to: .search)
        case .account:
            if #available(iOS 13, *) {
                Task {
                    let authService = Application.app.services.authentication
                    guard let user = authService.user else { return }
                    let request = UserHTTPDTO.Request(user: user)
                    let status = await authService.signOut(with: request)
                    
                    guard status else { return }
                    
                    mainQueueDispatch {
                        let coordinator = Application.app.coordinator
                        coordinator.coordinate(to: .auth)
                    }
                }
                
                return
            }
            
            let authService = Application.app.services.authentication
            authService.signOut()
            
            mainQueueDispatch {
                let coordinator = Application.app.coordinator
                coordinator.coordinate(to: .auth)
            }
        case .tvShows:
            navigationView.tvShowsItemViewContainer.isHidden(false)
            navigationView.moviesItemViewContainer.isHidden(true)
            navigationView.categoriesItemViewContainer.isHidden(false)
            navigationView.itemsCenterXConstraint.constant = -24.0
        case .movies:
            navigationView.tvShowsItemViewContainer.isHidden(true)
            navigationView.moviesItemViewContainer.isHidden(false)
            navigationView.categoriesItemViewContainer.isHidden(false)
            navigationView.itemsCenterXConstraint.constant = -32.0
        case .categories:
            break
        }
        
        navigationView.animateUsingSpring(withDuration: 0.33,
                                          withDamping: 0.7,
                                          initialSpringVelocity: 0.7)
    }
}

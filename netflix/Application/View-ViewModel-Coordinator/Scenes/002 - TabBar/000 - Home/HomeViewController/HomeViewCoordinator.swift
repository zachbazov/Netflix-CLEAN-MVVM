//
//  HomeViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - HomeViewCoordinator Type

final class HomeViewCoordinator {
    var viewController: HomeViewController?
    
    private(set) weak var detail: UINavigationController?
    private(set) weak var search: UINavigationController?
    private(set) weak var account: UINavigationController?
    
    deinit {
        viewController?.viewModel = nil
        viewController?.removeFromParent()
        viewController = nil
    }
}

// MARK: - Coordinator Implementation

extension HomeViewCoordinator: Coordinator {
    /// View representation type.
    enum Screen: Int {
        case detail
        case search
        case account
        case browse
    }
    
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .detail:
            detail = createDetailNavigationController()
            
            guard let navigation = detail else { return }
            
            viewController?.present(navigation, animated: true)
        case .search:
            search = createSearchNavigationController()
            
            guard let navigation = search, let view = viewController?.view else { return }
            viewController?.add(child: navigation, container: view)
            
            guard let controller = navigation.viewControllers.first as? SearchViewController else { return }
            controller.viewWillAnimateAppearance()
        case .account:
            account = createAccountNavigationController()
            
            guard let navigation = account, let view = viewController?.view else { return }
            viewController?.add(child: navigation, container: view)
            
            guard let controller = navigation.viewControllers.first as? AccountViewController else { return }
            controller.viewWillAnimateAppearance()
        case .browse:
            guard let controller = viewController else { return }
            
            controller.browseOverlayView?.viewModel.isPresentedWillChange(true)
        }
    }
}

// MARK: - Private Implementation

extension HomeViewCoordinator {
    private func createDetailNavigationController() -> UINavigationController? {
        let coordinator = DetailViewCoordinator()
        let controller = DetailViewController()
        let viewModel = DetailViewModel()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.view.backgroundColor = .black
        return navigation
    }
    
    private func createSearchNavigationController() -> UINavigationController {
        let coordinator = SearchViewCoordinator()
        let viewModel = SearchViewModel()
        let controller = SearchViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.search.rawValue
        return navigation
    }
    
    private func createAccountNavigationController() -> UINavigationController {
        let coordinator = AccountViewCoordinator()
        let viewModel = AccountViewModel()
        let controller = AccountViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        return navigation
    }
}

//
//  HomeViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    var detail: UINavigationController? { get }
    var search: UINavigationController? { get }
    var account: UINavigationController? { get }
    
    func createDetailNavigationController() -> UINavigationController?
    func createSearchNavigationController() -> UINavigationController
    func createAccountNavigationController() -> UINavigationController
    
    func deploy(_ screen: HomeViewCoordinator.Screen)
}

// MARK: - HomeViewCoordinator Type

final class HomeViewCoordinator {
    var viewController: HomeViewController?
    
    fileprivate weak var detail: UINavigationController?
    weak var search: UINavigationController?
    weak var account: UINavigationController?
}

// MARK: - CoordinatorProtocol Implementation

extension HomeViewCoordinator: CoordinatorProtocol {
    fileprivate func createDetailNavigationController() -> UINavigationController? {
        guard let homeViewModel = viewController?.viewModel else { return nil }
        
        guard let section = homeViewModel.detailSection,
              let media = homeViewModel.detailMedia
        else { return nil }
        
        // Allocate the controller and it's dependencies.
        let controller = DetailViewController()
        let viewModel = DetailViewModel(section: section, media: media, with: homeViewModel)
        
        // Allocate controller dependencies.
        controller.viewModel = viewModel
        controller.viewModel.coordinator = DetailViewCoordinator()
        controller.viewModel.coordinator?.viewController = controller
        controller.viewModel.isRotated = homeViewModel.shouldScreenRotate
        controller.viewModel.orientation.orientation = homeViewModel.shouldScreenRotate ? .landscapeLeft : .portrait
        
        // Wrap the controller with a navigation controller.
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.view.backgroundColor = .black
        return navigation
    }
    
    fileprivate func createSearchNavigationController() -> UINavigationController {
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
    
    func createAccountNavigationController() -> UINavigationController {
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
    
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .detail:
            guard let navigation = detail else { return }
            
            viewController?.present(navigation, animated: true)
        case .search:
            guard let navigation = search, let view = viewController?.view else { return }
            viewController?.add(child: navigation, container: view)
            
            guard let controller = navigation.viewControllers.first as? SearchViewController else { return }
            controller.viewWillAnimateAppearance()
        case .account:
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

// MARK: - Coordinate Implementation

extension HomeViewCoordinator: Coordinate {
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
        case .detail: detail = createDetailNavigationController()
        case .search: search = createSearchNavigationController()
        case .account: account = createAccountNavigationController()
        case .browse: break
        }
        
        deploy(screen)
    }
}

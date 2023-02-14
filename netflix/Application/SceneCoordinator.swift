//
//  SceneCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - SceneCoordinatorProtocol Protocol

private protocol SceneCoordinatorProtocol {
    func deployAuthDependencies()
    func deployTabBarDependencies()
}

// MARK: - SceneCoordinator Type

final class SceneCoordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? { didSet { viewController = window?.rootViewController } }
    private(set) var tabCoordinator: TabBarCoordinator!
    private(set) var tabViewModel: TabBarViewModel!
}

// MARK: - SceneCoordinatorProtocol Implementation

extension SceneCoordinator: SceneCoordinatorProtocol {
    /// Allocating and presenting the authorization screen.
    fileprivate func deployAuthDependencies() {
        let coordinator = AuthCoordinator()
        let viewModel = AuthViewModel()
        let controller = AuthController()
        // Allocate root's references.
        coordinator.viewController = controller
        viewModel.coordinator = coordinator
        controller.viewModel = viewModel
        window?.rootViewController = controller
        // Hide navigation bar.
        controller.setNavigationBarHidden(false, animated: false)
        // Instantiate authorization screen starting at the landpage.
        coordinator.deploy(screen: .landpage)
    }
    /// Allocating and presenting the tab bar screen.
    fileprivate func deployTabBarDependencies() {
        let controller = TabBarController()
        tabViewModel = TabBarViewModel()
        tabCoordinator = TabBarCoordinator()
        tabCoordinator.viewController = controller
        tabViewModel.coordinator = tabCoordinator
        controller.viewModel = tabViewModel
        window?.rootViewController = controller
        
        let authService = Application.app.services.authentication
        let requestDTO = UserHTTPDTO.Request(user: authService.user!)
        authService.signInRequest(requestDTO: requestDTO) { [weak self] in
            mainQueueDispatch {
                self?.tabCoordinator.deploy(screen: .home)
            }
        }
    }
}

// MARK: - Coordinate Implementation

extension SceneCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case auth
        case tabBar
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func deploy(screen: Screen) {
        if case .auth = screen { return deployAuthDependencies() }
        deployTabBarDependencies()
    }
}

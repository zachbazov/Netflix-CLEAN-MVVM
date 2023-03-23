//
//  Coordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    var viewController: UIViewController? { get }
    var window: UIWindow? { get }
    
    var authCoordinator: AuthCoordinator { get }
    var profileCoordinator: ProfileCoordinator { get }
    var tabCoordinator: TabBarCoordinator { get }
    
    func createAuthController() -> AuthController
    func createProfileController() -> ProfileViewController
    func createTabBarController() -> TabBarController
    
    func deploy(_ screen: Coordinator.Screen)
}

// MARK: - Coordinator Type

final class Coordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? { didSet { viewController = window?.rootViewController } }
    
    fileprivate(set) lazy var authCoordinator = AuthCoordinator()
    fileprivate(set) lazy var profileCoordinator = ProfileCoordinator()
    fileprivate(set) lazy var tabCoordinator = TabBarCoordinator()
}

// MARK: - CoordinatorProtocol Implementation

extension Coordinator: CoordinatorProtocol {
    /// Allocating and presenting the authorization screen.
    fileprivate func createAuthController() -> AuthController {
        let viewModel = AuthViewModel()
        let controller = AuthController()
        authCoordinator.viewController = controller
        viewModel.coordinator = authCoordinator
        controller.viewModel = viewModel
        return controller
    }
    
    /// Allocating and presenting the user profile selection screen.
    fileprivate func createProfileController() -> ProfileViewController {
        let controller = ProfileViewController()
        let viewModel = ProfileViewModel()
        profileCoordinator.viewController = controller
        viewModel.coordinator = profileCoordinator
        controller.viewModel = viewModel
        return controller
    }
    
    /// Allocating and presenting the tab bar screen.
    fileprivate func createTabBarController() -> TabBarController {
        let controller = TabBarController()
        let viewModel = TabBarViewModel()
        tabCoordinator.viewController = controller
        viewModel.coordinator = tabCoordinator
        controller.viewModel = viewModel
        return controller
    }
    
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .auth:
            authCoordinator.coordinate(to: .landpage)
        case .profile:
            profileCoordinator.coordinate(to: .userProfile)
        case .tabBar:
            tabCoordinator.coordinate(to: .home)
        }
    }
}

// MARK: - Coordinate Implementation

extension Coordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case auth
        case profile
        case tabBar
    }
    
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        var controller: UIViewController
        
        switch screen {
        case .auth:
            controller = createAuthController()
        case .profile:
            controller = createProfileController()
        case .tabBar:
            controller = createTabBarController()
        }
        
        window?.rootViewController = controller
        
        deploy(screen)
    }
}

//
//  Coordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorInput {
    func deploy(_ screen: Coordinator.Screen)
}

private protocol CoordinatorOutput {
    var viewController: UIViewController? { get }
    var window: UIWindow? { get }
    
    func createAuthController()
    func createTabBarController()
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - Coordinator Type

final class Coordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? { didSet { viewController = window?.rootViewController } }
    
    lazy var authCoordinator = AuthCoordinator()
    lazy var userProfileCoordinator = UserProfileCoordinator()
    lazy var tabCoordinator = TabBarCoordinator()
}

// MARK: - CoordinatorProtocol Implementation

extension Coordinator: CoordinatorProtocol {
    /// Allocating and presenting the authorization screen.
    func createAuthController() {
//        authCoordinator = AuthCoordinator()
        let viewModel = AuthViewModel()
        let controller = AuthController()
        authCoordinator.viewController = controller
        viewModel.coordinator = authCoordinator
        controller.viewModel = viewModel
        window?.rootViewController = controller
        
    }
    
    /// Allocating and presenting the tab bar screen.
    func createTabBarController() {
        tabCoordinator = TabBarCoordinator()
        let controller = TabBarController()
        let viewModel = TabBarViewModel()
        tabCoordinator.viewController = controller
        viewModel.coordinator = tabCoordinator
        controller.viewModel = viewModel
        window?.rootViewController = controller
    }
    
    func createUserProfileController() {
//        let controller = UserProfileViewController()
//        let viewModel = UserProfileViewModel()
//        userProfileCoordinator.viewController = controller
//        viewModel.coordinator = userProfileCoordinator
//        controller.viewModel = viewModel
        window?.rootViewController = userProfileCoordinator.userProfile
//        userProfileCoordinator.coordinate(to: .userProfile)
    }
    
    func deploy(_ screen: Screen) {
        switch screen {
        case .auth:
            authCoordinator.coordinate(to: .landpage)
        case .userProfile:
            userProfileCoordinator.coordinate(to: .userProfile)
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
        case userProfile
        case tabBar
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .auth: createAuthController()
        case .userProfile: createUserProfileController()
        case .tabBar: createTabBarController()
        }
        
        deploy(screen)
    }
}

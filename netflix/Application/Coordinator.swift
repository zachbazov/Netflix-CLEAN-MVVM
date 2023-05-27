//
//  Coordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

final class DI {
    static var shared = DI()
    
    private init() {}
    
    lazy var authCoordinator: AuthCoordinator = createAuthCoordinator()
    lazy var profileCoordinator: ProfileCoordinator = createProfileCoordinator()
    lazy var tabBarCoordinator: TabBarCoordinator = createTabBarCoordinator()
    
    func createAuthCoordinator() -> AuthCoordinator {
        let viewModel = createAuthViewModel()
        let controller = createAuthController()
        authCoordinator = AuthCoordinator()
        authCoordinator.viewController = controller
        viewModel.coordinator = authCoordinator
        controller.viewModel = viewModel
        return authCoordinator
    }
    
    private func createAuthViewModel() -> AuthViewModel {
        return AuthViewModel()
    }
    
    private func createAuthController() -> AuthController {
        return AuthController()
    }
    
    func createProfileCoordinator() -> ProfileCoordinator {
        let controller = ProfileController()
        let viewModel = ProfileViewModel()
        profileCoordinator = ProfileCoordinator()
        profileCoordinator.viewController = controller
        viewModel.coordinator = profileCoordinator
        controller.viewModel = viewModel
        return profileCoordinator
    }
    
    private func createProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel()
    }
    
    private func createProfileController() -> ProfileController {
        return ProfileController()
    }
    
    func createTabBarCoordinator() -> TabBarCoordinator {
        let controller = TabBarController()
        let viewModel = TabBarViewModel()
        tabBarCoordinator = TabBarCoordinator()
        tabBarCoordinator.viewController = controller
        viewModel.coordinator = tabBarCoordinator
        controller.viewModel = viewModel
        return tabBarCoordinator
    }
    
    private func createTabBarViewModel() -> TabBarViewModel {
        return TabBarViewModel()
    }
    
    private func createTabBarController() -> TabBarController {
        return TabBarController()
    }
}

// MARK: - Coordinator Type

final class Coordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? { didSet { viewController = window?.rootViewController } }
    
    fileprivate(set) lazy var authCoordinator = DI.shared.createAuthCoordinator()
    fileprivate(set) lazy var profileCoordinator = DI.shared.createProfileCoordinator()
    fileprivate(set) var tabCoordinator: TabBarCoordinator?
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
        switch screen {
        case .auth:
            window?.rootViewController = authCoordinator.viewController
            
            authCoordinator.coordinate(to: .landpage)
        case .profile:
            window?.rootViewController = profileCoordinator.viewController
            
            profileCoordinator.coordinate(to: .userProfile)
        case .tabBar:
            tabCoordinator = DI.shared.createTabBarCoordinator()
            
            window?.rootViewController = tabCoordinator?.viewController
            
            tabCoordinator?.coordinate(to: .home)
        }
    }
}

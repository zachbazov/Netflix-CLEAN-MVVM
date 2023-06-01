//
//  RootCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - RootCoordinator Type

final class RootCoordinator {
    var authCoordinator: AuthCoordinator?
    var profileCoordinator: ProfileCoordinator?
    var tabCoordinator: TabBarCoordinator?
    
    weak var viewController: UIViewController?
    weak var window: UIWindow? {
        didSet {
            viewController = window?.rootViewController
        }
    }
}

// MARK: - Coordinator Implementation

extension RootCoordinator: Coordinator {
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
            authCoordinator = createAuthCoordinator()
            
            window?.rootViewController = authCoordinator?.viewController
            
            authCoordinator?.coordinate(to: .landpage)
        case .profile:
            if authCoordinator != nil {
                deallocateAuth()
            }
            
            profileCoordinator = createProfileCoordinator()
            
            window?.rootViewController = profileCoordinator?.viewController
            
            profileCoordinator?.coordinate(to: .userProfile)
        case .tabBar:
            if profileCoordinator != nil {
                deallocateProfile()
            }
            
            tabCoordinator = createTabBarCoordinator()
            
            window?.rootViewController = tabCoordinator?.viewController
            
            tabCoordinator?.coordinate(to: .home)
        }
    }
}

// MARK: - Private Implementation

extension RootCoordinator {
    private func createAuthCoordinator() -> AuthCoordinator {
        let coordinator = AuthCoordinator()
        let controller = AuthController()
        let viewModel = AuthViewModel()
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        return coordinator
    }
    
    private func createProfileCoordinator() -> ProfileCoordinator {
        let controller = ProfileController()
        let viewModel = ProfileViewModel()
        let coordinator = ProfileCoordinator()
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        return coordinator
    }
    
    private func createTabBarCoordinator() -> TabBarCoordinator {
        let controller = TabBarController()
        let viewModel = TabBarViewModel()
        let coordinator = TabBarCoordinator()
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        return coordinator
    }
    
    private func didDeallocate() {
        window?.rootViewController?.removeFromParent()
        window?.rootViewController = nil
        
        viewController?.removeFromParent()
        viewController = nil
    }
    
    private func deallocateAuth() {
        authCoordinator?.removeViewControllers()
        authCoordinator = nil
        
        didDeallocate()
    }
    
    func deallocateTabBar() {
        tabCoordinator?.removeViewControllers()
        tabCoordinator = nil
        
        didDeallocate()
    }
    
    private func deallocateProfile() {
        profileCoordinator?.removeViewControllers()
        profileCoordinator = nil
        
        didDeallocate()
    }
}

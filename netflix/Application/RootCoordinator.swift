//
//  RootCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - RootCoordinable Protocol

private protocol RootCoordinable {
    func allocateAuthScreen()
    func allocateTabBarScreen()
}

// MARK: - RootCoordinator Type

final class RootCoordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? { didSet { viewController = window?.rootViewController } }
    private(set) var tabCoordinator: TabBarCoordinator!
    private(set) var tabViewModel: TabBarViewModel!
}

// MARK: - RootCoordinable Implementation

extension RootCoordinator: RootCoordinable {
    /// Allocating and presenting the authorization screen.
    fileprivate func allocateAuthScreen() {
        let coordinator = AuthCoordinator()
        let viewModel = AuthViewModel()
        let controller = AuthController()
        /// Allocate root's references.
        coordinator.viewController = controller
        viewModel.coordinator = coordinator
        controller.viewModel = viewModel
        window?.rootViewController = controller
        /// Hide navigation bar.
        controller.setNavigationBarHidden(false, animated: false)
        /// Instantiate authorization screen starting from the landpage.
        coordinator.showScreen(.landpage)
    }
    /// Allocating and presenting the tab bar screen.
    fileprivate func allocateTabBarScreen() {
        let controller = TabBarController()
        if tabViewModel == nil { tabViewModel = TabBarViewModel() }
        if tabCoordinator == nil { tabCoordinator = TabBarCoordinator() }
        tabViewModel.coordinator = tabCoordinator
        controller.viewModel = tabViewModel
        controller.viewModel.coordinator = tabCoordinator
        tabCoordinator.viewController = controller
        self.viewController = controller
        window?.rootViewController = controller
        
        let authService = Application.current.authService
        let requestDTO = AuthRequestDTO(user: authService.user!)
        authService.signInRequest(request: requestDTO) { [weak self] in
            asynchrony {
                self?.tabCoordinator.showScreen(.home)
            }
        }
    }
}

// MARK: - Coordinate Implementation

extension RootCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case auth
        case tabBar
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func showScreen(_ screen: Screen) {
        if case .auth = screen { allocateAuthScreen() }
        else { allocateTabBarScreen() }
    }
}

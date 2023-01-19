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
        /// Both `tabViewModel` and `tabCoordinator` are wrapped due to
        /// reallocation possibility by the user,
        /// as the state of the navigation view in `HomeViewController` changes.
        /// Hence, to avoid any memory issues...
        /// single instance should suffice to fill this app requirements to represent data efficiently.
        if tabViewModel == nil { tabViewModel = TabBarViewModel() }
        if tabCoordinator == nil { tabCoordinator = TabBarCoordinator() }
        /// Allocate root's references.
        tabViewModel.coordinator = tabCoordinator
        controller.viewModel = tabViewModel
        controller.viewModel.coordinator = tabCoordinator
        tabCoordinator.viewController = controller
        self.viewController = controller
        window?.rootViewController = controller
        /// An authorization protection layer.
        /// In-order for all the features to work properly,
        /// an authentication procedure is required.
        asynchrony { [weak self] in
            guard let self = self else { return }
            self.tabCoordinator.showScreen(.home)
        }
//        Application.current.authService.cachedAuthorizationRequest() {
//            asynchrony { [weak self] in
//                guard let self = self else { return }
//                self.tabCoordinator.allocateViewControllers()
//            }
//        }
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

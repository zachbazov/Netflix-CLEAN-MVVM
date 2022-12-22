//
//  RootCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

private protocol RootCoordinable {
    func allocateAuthScreen()
    func allocateTabBarScreen()
    func reallocateTabController()
}

final class RootCoordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? { didSet { viewController = window?.rootViewController } }
    private(set) var tabCoordinator: TabBarCoordinator!
    private(set) var tabViewModel: TabBarViewModel!
}

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
        tabCoordinator.requestUserCredentials()
    }
    /// Reallocate tab bar controller and it's children.
    /// In terms of memory-wise, i've found it to be a better approach,
    /// to just terminate, store any essential properties, and reallocate the whole tab controller,
    /// instead of `reloadData()` used in collection types.
    func reallocateTabController() {
        /// Deallocate `homeCache` data from memory.
        AsyncImageFetcher.shared.cache.removeAllObjects()
        /// In-case there are valid children for root's coordinator, else eject.
        guard let homeNavigation = tabCoordinator.viewController?.viewControllers?.first! as! UINavigationController?,
              let homeViewController = homeNavigation.viewControllers.first! as! HomeViewController? else {
            return
        }
        /// Initiate `terminate()` operations to deallocate any objects referenced
        /// from `HomeViewController` group.
        homeViewController.dataSource.displayCell.terminate()
        homeViewController.dataSource.terminate()
        homeViewController.terminate()
        /// Deallocate root references for the old instance.
        tabCoordinator.viewController = nil
        tabCoordinator.viewController?.viewModel.coordinator = nil
        /// Deallocate root view controller.
        viewController = nil
        /// Once terminated, instantiate a new tab bar screen.
        allocateTabBarScreen()
    }
}

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

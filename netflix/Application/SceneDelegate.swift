//
//  SceneDelegate.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        /// Apply application appearance configurations.
        AppAppearance.setupAppearance()
        /// Allocate root's references.
        window = UIWindow(windowScene: windowScene)
        Application.current.root(in: window)
        /// Stack and present the window.
        window?.makeKeyAndVisible()
    }
    
    /// Top level ejection point.
    /// - Parameter scene: Current window's sceneto be ejected.
    func sceneDidDisconnect(_ scene: UIScene) {
        removeTabBarObservers()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

extension SceneDelegate {
    private func removeTabBarObservers() {
        /// Remove `HomeViewController` observers.
        /// The observers of `DetailViewController` will be removed once home's instance is deallocated.
        if let tabCoordinator = Application.current.rootCoordinator.tabCoordinator,
           let homeController = tabCoordinator.home.viewControllers.first! as? HomeViewController {
            /// Remove home's data source display children observers.
            if let displayCell = homeController.dataSource.displayCell,
               let panelView = displayCell.displayView.panelView as PanelView? {
                panelView.removeObservers()
            }
            /// Remove home's navigation view and view's overlay observers.
            if let navigationView = homeController.navigationView,
               let navigationOverlayView = navigationView.navigationOverlayView {
                navigationView.removeObservers()
                navigationOverlayView.removeObservers()
            }
            /// Remove my list observers.
            if let myList = homeController.viewModel.myList {
                myList.removeObservers()
            }
            /// Remove home's view model observers.
            homeController.removeObservers()
        }
        /// Remove `NewsViewController` observers.
        if let tabCoordinator = Application.current.rootCoordinator.tabCoordinator,
           let newsController = tabCoordinator.news.viewControllers.first! as? NewsViewController {
            newsController.removeObservers()
        }
        /// Remove `SearchViewController` observers.
        if let tabCoordinator = Application.current.rootCoordinator.tabCoordinator,
           let searchController = tabCoordinator.search.viewControllers.first! as? SearchViewController {
            searchController.removeObservers()
        }
    }
}

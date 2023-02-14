//
//  SceneDelegate.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - SceneDelegate Type

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIWindowSceneDelegate Protocol

extension SceneDelegate: UIWindowSceneDelegate {
    /// Occurs once the scene is about to connect to the app.
    /// - Parameters:
    ///   - scene: Corresponding scene.
    ///   - session: Scene's session.
    ///   - connectionOptions: Scene's options to apply.
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Apply application appearance configurations.
        AppAppearance.default()
        // Allocate root's references.
        window = UIWindow(windowScene: windowScene)
        // Deploy the application.
        Application.app.deployScene(in: window)
    }
    /// Occurs once the scene has been disconnected from the app.
    /// - Parameter scene: Corresponding scene.
    func sceneDidDisconnect(_ scene: UIScene) {
        ejectTabBarObservers()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

// MARK: - TabBarEjectable Implementation

extension SceneDelegate: TabBarEjectable {
    /// Remove all tar-bar related observers.
    /// The observers of `DetailViewController` will be removed automatically once home's instance is deallocated.
    func ejectTabBarObservers() {
        guard let tabCoordinator = Application.app.sceneCoordinator.tabCoordinator else { return }
        // Remove any home-related observers.
        if let homeController = tabCoordinator.home.viewControllers.first! as? HomeViewController {
            // Remove panel view observers.
            if let displayCell = homeController.dataSource.displayCell,
               let panelView = displayCell.displayView.panelView as PanelView? {
                panelView.removeObservers()
            }
            // Remove navigation & navigation overlay views observers.
            if let navigationView = homeController.navigationView,
               let navigationOverlayView = navigationView.navigationOverlayView {
                navigationView.removeObservers()
                navigationOverlayView.removeObservers()
            }
            // Remove my-list observers.
            if let myList = homeController.viewModel.myList {
                myList.removeObservers()
            }
            
            homeController.removeObservers()
        }
        // In-case of a valid news controller instance, remove it's observers.
        if let newsController = tabCoordinator.news.viewControllers.first! as? NewsViewController {
            newsController.removeObservers()
        }
        // In-case of a valid search controller instance, remove it's observers.
        if let searchController = tabCoordinator.search.viewControllers.first! as? SearchViewController {
            searchController.removeObservers()
        }
    }
}

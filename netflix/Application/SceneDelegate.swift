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
        if let tabCoordinator = Application.current.rootCoordinator.tabCoordinator,
           let homeViewController = tabCoordinator.home.viewControllers.first! as? HomeViewController {
            
            if let displayCell = homeViewController.dataSource.displayCell,
               let panelView = displayCell.displayView.panelView as PanelView? {
                panelView.removeObservers()
            }
            if let navigationView = homeViewController.navigationView,
               let navigationOverlayView = navigationView.navigationOverlayView {
                navigationView.removeObservers()
                navigationOverlayView.removeObservers()
            }
            if let myList = homeViewController.viewModel.myList {
                myList.removeObservers()
            }
            
            homeViewController.removeObservers()
            
            printIfDebug("Removed `HomeViewController` observers successfully.")
        }
    }
}

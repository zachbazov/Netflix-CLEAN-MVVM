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

// MARK: - UIWindowSceneDelegate Implementation

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
        Theme.default()
        // Allocate root's references.
        window = UIWindow(windowScene: windowScene)
        // Deploy the application.
        let application = Application.app
        application.deployScene(in: window)
    }
    /// Occurs once the scene has been disconnected from the app.
    /// - Parameter scene: Corresponding scene.
    func sceneDidDisconnect(_ scene: UIScene) {
        sceneObserversDidUnbind()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

// MARK: - SceneObserverUnbinding Implementation

extension SceneDelegate: SceneObserverUnbinding {
    /// Remove all tar-bar related observers.
    /// The observers of `DetailViewController` will be removed automatically once home's instance is deallocated.
    func sceneObserversDidUnbind() {
        guard let tabCoordinator = Application.app.coordinator.tabCoordinator as TabBarCoordinator? else { return }
        
        // Remove any home-related observers.
        if let homeController = tabCoordinator.viewController?.homeViewController {
            // Remove navigation & navigation overlay views observers.
            if let navigationBar = homeController.navigationView?.navigationBar {
                navigationBar.viewWillUnbindObservers()
            }
            
            if let segmentControl = homeController.navigationView?.segmentControl {
                segmentControl.viewWillUnbindObservers()
            }
            
            if let navigationOverlay = homeController.navigationOverlay {
                navigationOverlay.viewWillUnbindObservers()
            }
            
            if let browseOverlay = homeController.browseOverlayView {
                browseOverlay.viewWillUnbindObservers()
            }
            
            homeController.viewWillUnbindObservers()
        }
        
        // In-case of a valid news controller instance, remove it's observers.
        if let newsController = tabCoordinator.viewController?.newsViewController {
            newsController.viewDidUnbindObservers()
        }
    }
}

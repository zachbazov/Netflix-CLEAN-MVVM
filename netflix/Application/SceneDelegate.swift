//
//  SceneDelegate.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - SceneDelegate class

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIWindowSceneDelegate implementation

extension SceneDelegate: UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        AppAppearance.setupAppearance()
        
        window = UIWindow(windowScene: windowScene)
        
        Application.current.root(in: window)
        
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
//        appFlowCoordinator.homeFlowCoordinator.sceneDidDisconnect()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

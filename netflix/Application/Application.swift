//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ApplicationProtocol Protocol

private protocol ApplicationProtocol {
    var sceneCoordinator: SceneCoordinator { get }
    
    func deployScene(in window: UIWindow?)
}

// MARK: - Application Type

final class Application {
    static let app = Application()
    private init() {}
    
    private(set) lazy var services = AppServices()
    private(set) lazy var stores = AppStores(services: services)
    
    let sceneCoordinator = SceneCoordinator()
}

// MARK: - Private Methods

extension Application {
    /// Check for the last signed authentication response by the user.
    /// In case there is a valid response present the TabBar screen.
    /// In case there isn't a valid response present the Auth screen.
    private func cachedAuthorizationResponse() {
        services.authentication.response { [weak self] userDTO in
            guard let self = self else { return }
            guard userDTO != nil else { return self.sceneCoordinator.deploy(screen: .auth) }
            self.sceneCoordinator.deploy(screen: .tabBar)
        }
    }
}

// MARK: - ApplicationProtocol Implementation

extension Application: ApplicationProtocol {
    /// Main entry-point for the app.
    /// Allocate a root view controller for the window.
    /// - Parameter window: Application's root window.
    func deployScene(in window: UIWindow?) {
        sceneCoordinator.window = window
        // Stack and present the window.
        window?.makeKeyAndVisible()
        // Check for the latest signed response by the user.
        cachedAuthorizationResponse()
    }
}

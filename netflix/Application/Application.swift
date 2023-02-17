//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ApplicationProtocol Type

private protocol ApplicationInput {
    func deployScene(in window: UIWindow?)
    func resignUserFromCachedData()
}

private protocol ApplicationOutput {
    var dependencies: Application.Dependencies { get }
}

private typealias ApplicationProtocol = ApplicationInput & ApplicationOutput

// MARK: - Application Type

final class Application {
    static let app = Application()
    private init() {}
    
    struct Dependencies {
        let coordinator: Coordinator
        let services: Services
        let stores: Stores
    }
    
    let container = Container()
    lazy var dependencies = container.createApplicationDependencies()
}

// MARK: - ApplicationProtocol Implementation

extension Application: ApplicationProtocol {
    /// Check for the last signed authentication response by the user.
    /// In case there is a valid response present the TabBar screen.
    /// In case there isn't a valid response present the Auth screen.
    fileprivate func resignUserFromCachedData() {
        dependencies.services.authentication.resign { [weak self] userDTO in
            guard let self = self else { return }
            guard userDTO != nil else {
                return self.dependencies.coordinator.coordinate(to: .auth)
            }
            self.dependencies.coordinator.coordinate(to: .tabBar)
        }
    }
    /// Allocate a root view controller for the window.
    /// - Parameter window: Application's root window.
    func deployScene(in window: UIWindow?) {
        dependencies.coordinator.window = window
        // Stack and present the window.
        window?.makeKeyAndVisible()
        // Check for the latest signed response by the user.
        resignUserFromCachedData()
    }
}

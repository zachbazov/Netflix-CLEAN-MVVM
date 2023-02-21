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
}

private protocol ApplicationOutput {
    var coordinator: Coordinator { get }
    var services: Services { get }
    var stores: Stores { get }
    
    func resign()
}

private typealias ApplicationProtocol = ApplicationInput & ApplicationOutput

// MARK: - Application Type

final class Application {
    static let app = Application()
    private init() {}
    
    lazy var coordinator = Coordinator()
    lazy var services = Services()
    lazy var stores = Stores(services: services)
}

// MARK: - ApplicationProtocol Implementation

extension Application: ApplicationProtocol {
    /// Check for the last signed authentication response by the user.
    /// In case there is a valid response present the TabBar screen.
    /// In case there isn't a valid response present the Auth screen.
    fileprivate func resign() {
        services.authentication.resign { [weak self] userDTO in
            guard let self = self else { return }
            guard userDTO != nil else {
                return self.coordinator.coordinate(to: .auth)
            }
            self.coordinator.coordinate(to: .tabBar)
        }
    }
    /// Allocate a root view controller for the window.
    /// - Parameter window: Application's root window.
    func deployScene(in window: UIWindow?) {
        coordinator.window = window
        // Stack and present the window.
        window?.makeKeyAndVisible()
        // Check for the latest signed response by the user.
        resign()
    }
}

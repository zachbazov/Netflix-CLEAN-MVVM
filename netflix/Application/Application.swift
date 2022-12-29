//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ApplicationRooting Protocol

private protocol ApplicationRooting {
    func root(in window: UIWindow?)
}

// MARK: - Application Type

final class Application {
    
    // MARK: Singleton Pattern
    
    static let current = Application()
    private init() {}
    
    // MARK: Properties
    
    let rootCoordinator = RootCoordinator()
    let configuration = AppConfiguration()
    let authService = AuthService()
    
    private(set) lazy var dataTransferService: DataTransferService = createDataTransferService()
    private(set) lazy var authResponseCache: AuthResponseStorage = AuthResponseStorage(authService: authService)
    private(set) lazy var mediaResponseCache: MediaResponseStorage = MediaResponseStorage()
}

// MARK: - Private Methods

extension Application {
    /// Allocate the service that manages the application networking.
    /// - Returns: A data transfer service object.
    private func createDataTransferService() -> DataTransferService {
        let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
        let config = NetworkConfig(baseURL: url)
        let networkService = NetworkService(config: config)
        return DataTransferService(networkService: networkService)
    }
}

// MARK: - ApplicationRooting Implementation

extension Application: ApplicationRooting {
    /// Main entry-point for the app.
    /// Allocate a root view controller for the window.
    /// - Parameter window: Application's root window.
    func root(in window: UIWindow?) {
        rootCoordinator.window = window
        // In-case there is a previously registered sign by the user, present the tab-bar screen.
        if authService.latestCachedUser != nil {
            rootCoordinator.showScreen(.tabBar)
            return
        }
        // Otherwise, present the authorization screen.
        rootCoordinator.showScreen(.auth)
    }
}

//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - Applicable Protocol

private protocol Applicable {
    func root(in window: UIWindow?)
}

// MARK: - Application Type

final class Application {
    static let current = Application()
    private init() {}
    
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
    /// Check for the last signed authentication response by the user.
    /// In case there is a valid response present the TabBar screen.
    /// In case there isn't a valid response present the Auth screen.
    private func cachedAuthorizationResponse() {
        authService.response { [weak self] userDTO in
            guard let self = self else { return }
            // Present the screen according to the response.
            userDTO != nil ? self.rootCoordinator.showScreen(.tabBar) : self.rootCoordinator.showScreen(.auth)
        }
    }
}

// MARK: - Applicable Implementation

extension Application: Applicable {
    /// Main entry-point for the app.
    /// Allocate a root view controller for the window.
    /// - Parameter window: Application's root window.
    func root(in window: UIWindow?) {
        rootCoordinator.window = window
        // Check for the latest signed response by the user.
        cachedAuthorizationResponse()
    }
}

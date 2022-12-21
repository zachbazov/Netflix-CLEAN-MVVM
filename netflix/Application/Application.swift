//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

final class Application {
    /// Singleton pattern.
    static let current = Application()
    private init() {}
    
    let rootCoordinator = RootCoordinator()
    let configuration = AppConfiguration()
    let authService = AuthService()
    
    private(set) lazy var dataTransferService: DataTransferService = createDataTransferService()
    private(set) lazy var authResponseCache: AuthResponseStorage = AuthResponseStorage(authService: authService)
    private(set) lazy var mediaResponseCache: MediaResponseStorage = MediaResponseStorage()
    /// Allocate a root view controller for the window.
    /// - Parameter window: Application's root window.
    func root(in window: UIWindow?) {
        rootCoordinator.window = window
        /// In-case there is a previously registered sign by the user,
        /// present the `TabBar` screen.
        if authService.latestCachedUser != nil {
            rootCoordinator.showScreen(.tabBar)
            return
        }
        /// Else, present the `Auth` screen.
        rootCoordinator.showScreen(.auth)
    }
}

extension Application {
    /// Allocate the service that manages the application networking.
    /// - Returns: API's data transfer object service.
    private func createDataTransferService() -> DataTransferService {
        let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
        let config = NetworkConfig(baseURL: url)
        let networkService = NetworkService(config: config)
        return DataTransferService(with: networkService)
    }
}

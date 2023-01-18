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
        
        authResponseCache.getResp { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                asynchrony {
                    // In-case there is a previously registered sign by the user, present the tab-bar screen.
                    if let user = response?.data {
                        let userDTO = user
                        userDTO.password = response?.request?.user.password
                        
                        self.authService.user = userDTO
                        
                        self.rootCoordinator.showScreen(.tabBar)
                        return
                    }
                    // Otherwise, present the authorization screen.
                    self.rootCoordinator.showScreen(.auth)
                }
            case .failure(let error):
                printIfDebug(.debug, "respError \(error)")
            }
        }
    }
}





//@propertyWrapper
//struct UserDefault<T: Codable> {
//    let key: String
//    let defaultValue: T
//
//    var wrappedValue: T {
//        get {
//            if let data = UserDefaults.standard.object(forKey: key) as? Data,
//               let user = try? JSONDecoder().decode(T.self, from: data) {
//                return user
//            }
//            return defaultValue
//        }
//        set {
//            if let encoded = try? JSONEncoder().encode(newValue) {
//                UserDefaults.standard.set(encoded, forKey: key)
//            }
//        }
//    }
//}
//
//enum UserGlobal {
//    @UserDefault(key: "latestAuthenticationOnDevice", defaultValue: UserDTO()) static var user: UserDTO?
//    @UserDefault(key: "latestAuthenticationPasswordOnDevice", defaultValue: String()) static var password: String?
//}

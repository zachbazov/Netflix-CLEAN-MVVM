//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ApplicationLaunching Type

private protocol ApplicationLaunching {
    func appDidLaunch(in window: UIWindow?)
}

// MARK: - ApplicationAuthenticating Type

private protocol ApplicationAuthenticating {
    func appDidResign()
    func appDidEndResigning(for user: UserDTO?)
}

// MARK: - ApplicationCoordinating Type

private protocol ApplicationCoordinating {
    func sceneDidDeploy(in window: UIWindow?)
    func coordinate(to screen: Coordinator.Screen)
}

// MARK: - Application Type

final class Application {
    static let app = Application()
    
    private init() {}
    
    private(set) lazy var coordinator = Coordinator()
    private(set) lazy var services = Services()
    private(set) lazy var stores = Stores(services: services)
}

// MARK: - ApplicationLaunching Implementation

extension Application: ApplicationLaunching {
    func appDidLaunch(in window: UIWindow?) {
        sceneDidDeploy(in: window)
        
        appDidResign()
    }
}

// MARK: - ApplicationAuthenticating Implementation

extension Application: ApplicationAuthenticating {
    fileprivate func appDidResign() {
        if #available(iOS 13.0, *) {
            Task {
                let user = await services.authentication.resign()
                
                appDidEndResigning(for: user)
            }
            
            return
        }
        
        services.authentication.resign { [weak self] user in
            guard let self = self else { return }
            
            self.appDidEndResigning(for: user)
        }
    }
    
    fileprivate func appDidEndResigning(for user: UserDTO?) {
        printIfDebug(.debug, "1")
        guard let user = user else {
            return coordinate(to: .auth)
        }
        printIfDebug(.debug, "2")
        guard let selectedProfile = user.selectedProfile,
              let profiles = user.profiles,
              profiles.contains(where: { $0 == selectedProfile }) else {
            return coordinate(to: .profile)
        }
        printIfDebug(.debug, "3")
        coordinate(to: .tabBar)
    }
}

// MARK: - ApplicationProtocol Implementation

extension Application: ApplicationCoordinating {
    fileprivate func sceneDidDeploy(in window: UIWindow?) {
        coordinator.window = window
        
        window?.makeKeyAndVisible()
    }
    
    fileprivate func coordinate(to screen: Coordinator.Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.coordinator.coordinate(to: screen)
        }
    }
}

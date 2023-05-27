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
    func resignUserSession()
    func handleResignedSession(for user: UserDTO?)
}

// MARK: - ApplicationCoordinating Type

private protocol ApplicationCoordinating {
    func setWindow(_ window: UIWindow?)
    func coordinate(to screen: RootCoordinator.Screen)
}

// MARK: - Application Type

final class Application {
    static let app = Application()
    
    private init() {}
    
    private(set) lazy var coordinator = RootCoordinator()
    private(set) lazy var services = Services()
    private(set) lazy var stores = Stores(services: services)
}

// MARK: - ApplicationLaunching Implementation

extension Application: ApplicationLaunching {
    func appDidLaunch(in window: UIWindow?) {
        setWindow(window)
        
        resignUserSession()
    }
}

// MARK: - ApplicationAuthenticating Implementation

extension Application: ApplicationAuthenticating {
    fileprivate func resignUserSession() {
        if #available(iOS 13.0, *) {
            Task {
                let user = await services.authentication.resign()
                
                handleResignedSession(for: user)
            }
            
            return
        }
        
        services.authentication.resign { [weak self] user in
            guard let self = self else { return }
            
            self.handleResignedSession(for: user)
        }
    }
    
    fileprivate func handleResignedSession(for user: UserDTO?) {
        guard let user = user else {
            return coordinate(to: .auth)
        }
        
        guard let selectedProfile = user.selectedProfile,
              let profiles = user.profiles,
              profiles.contains(where: { $0 == selectedProfile }) else {
            return coordinate(to: .profile)
        }
        
        coordinate(to: .tabBar)
    }
}

// MARK: - ApplicationCoordinating Implementation

extension Application: ApplicationCoordinating {
    fileprivate func setWindow(_ window: UIWindow?) {
        coordinator.window = window
        
        window?.makeKeyAndVisible()
    }
    
    fileprivate func coordinate(to screen: RootCoordinator.Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.coordinator.coordinate(to: screen)
        }
    }
}

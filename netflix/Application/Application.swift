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
    func deployScene(in window: UIWindow?)
    func coordinate(to screen: Coordinator.Screen)
}

// MARK: - Application Type

final class Application {
    static let app = Application()
    
    private let dependencies = DI.shared
    
    private init() {}
    
    lazy var coordinator = dependencies.resolve(Coordinator.self)
    lazy var services = dependencies.resolve(Services.self)
    lazy var stores = dependencies.resolve(Stores.self)
}

// MARK: - ApplicationLaunching Implementation

extension Application: ApplicationLaunching {
    func appDidLaunch(in window: UIWindow?) {
        deployScene(in: window)
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
        guard let user = user else { return coordinate(to: .auth) }
        
        guard let selectedProfile = user.selectedProfile,
              let profiles = user.profiles,
              profiles.contains(where: { $0 == selectedProfile })
        else { return coordinate(to: .profile) }
        
        coordinate(to: .tabBar)
    }
}

// MARK: - ApplicationProtocol Implementation

extension Application: ApplicationCoordinating {
    fileprivate func deployScene(in window: UIWindow?) {
        coordinator.window = window
        
        window?.makeKeyAndVisible()
        
        appDidResign()
    }
    
    fileprivate func coordinate(to screen: Coordinator.Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.coordinator.coordinate(to: screen)
        }
    }
}

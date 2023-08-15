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
    
    private(set) lazy var configuration = Configuration()
    private(set) lazy var services = Services()
    private(set) lazy var stores = Stores()
    private(set) lazy var coordinator = RootCoordinator()
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
        stores.userResponses.getResponse { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let request = response?.request else {
                    mainQueueDispatch {
                        self.coordinate(to: .auth)
                    }
                    return
                }
                
                self.services.auth.signIn(for: request) { (user) in
                    mainQueueDispatch {
                        if let _ = user?.selectedProfile {
                            self.coordinate(to: .tabBar)
                            
                            return
                        }
                        
                        self.coordinate(to: .profile)
                    }
                }
            case .failure(let error):
                printIfDebug(.error, "\(error)")
            }
        }
    }
}

// MARK: - ApplicationCoordinating Implementation

extension Application: ApplicationCoordinating {
    fileprivate func setWindow(_ window: UIWindow?) {
        coordinator.window = window
        coordinator.window?.makeKeyAndVisible()
    }
    
    fileprivate func coordinate(to screen: RootCoordinator.Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.coordinator.coordinate(to: screen)
        }
    }
}

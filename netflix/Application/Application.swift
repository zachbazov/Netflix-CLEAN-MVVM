//
//  Application.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ApplicationProtocol Type

private protocol ApplicationProtocol {
    var coordinator: Coordinator { get }
    var services: Services { get }
    var stores: Stores { get }
    
    func resign()
    func didFinishResigning(with user: UserDTO?)
    func deployScene(in window: UIWindow?)
    func coordinate(to screen: Coordinator.Screen)
}

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
        if #available(iOS 13.0, *) {
            Task {
                let user = await services.authentication.resign()
                
                didFinishResigning(with: user)
            }
            
            return
        }
        
        services.authentication.resign { [weak self] user in
            guard let self = self else { return }
            
            self.didFinishResigning(with: user)
        }
    }
    
    /// Based on the corresponding user, navigate to a screen.
    /// In case there is a valid user, navigate to the tab bat screen.
    /// In case there isn't, navigate to the auth screen.
    /// - Parameter user: Corresponding user object.
    fileprivate func didFinishResigning(with user: UserDTO?) {
        guard let user = user else { return coordinate(to: .auth) }
        
        guard let selectedProfile = user.selectedProfile,
              let profiles = user.profiles,
              profiles.contains(where: { $0 == selectedProfile }) else {
            return coordinate(to: .profile)
        }
        
        coordinate(to: .tabBar)
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
    
    fileprivate func coordinate(to screen: Coordinator.Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            self.coordinator.coordinate(to: screen)
        }
    }
}

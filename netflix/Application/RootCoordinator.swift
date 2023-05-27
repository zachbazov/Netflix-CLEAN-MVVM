//
//  RootCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - RootCoordinator Type

final class RootCoordinator {
    weak var viewController: UIViewController?
    weak var window: UIWindow? {
        didSet {
            viewController = window?.rootViewController
        }
    }
    
    private(set) lazy var authCoordinator: AuthCoordinator = DI.shared.resolve(AuthCoordinator.self)
    private(set) lazy var profileCoordinator: ProfileCoordinator = DI.shared.resolve(ProfileCoordinator.self)
    private(set) var tabCoordinator: TabBarCoordinator?
}

// MARK: - Coordinator Implementation

extension RootCoordinator: Coordinator {
    /// View representation type.
    enum Screen {
        case auth
        case profile
        case tabBar
    }
    
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .auth:
            window?.rootViewController = authCoordinator.viewController
            
            authCoordinator.coordinate(to: .landpage)
        case .profile:
            window?.rootViewController = profileCoordinator.viewController
            
            profileCoordinator.coordinate(to: .userProfile)
        case .tabBar:
            tabCoordinator = DI.shared.resolve(TabBarCoordinator.self)
            
            window?.rootViewController = tabCoordinator?.viewController
            
            tabCoordinator?.coordinate(to: .home)
        }
    }
}

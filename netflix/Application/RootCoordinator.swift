//
//  RootCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - RootCoordinator Type

final class RootCoordinator {
    private let dependencies: DI = DI.shared
    
    private(set) lazy var authCoordinator: AuthCoordinator = dependencies.resolve(AuthCoordinator.self)
    private(set) lazy var profileCoordinator: ProfileCoordinator = dependencies.resolve(ProfileCoordinator.self)
    private(set) lazy var tabCoordinator: TabBarCoordinator = dependencies.resolve(TabBarCoordinator.self)
    
    weak var viewController: UIViewController?
    weak var window: UIWindow? {
        didSet {
            viewController = window?.rootViewController
        }
    }
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
            
            window?.rootViewController = tabCoordinator.viewController
            
            tabCoordinator.coordinate(to: .home)
        }
    }
}

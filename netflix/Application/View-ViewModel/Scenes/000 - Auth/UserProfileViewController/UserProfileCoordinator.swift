//
//  UserProfileCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorInput {
    func deploy(_ screen: UserProfileCoordinator.Screen)
}

private protocol CoordinatorOutput {
    
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - UserProfileCoordinator Type

final class UserProfileCoordinator {
    var viewController: UserProfileViewController?
}

// MARK: - CoordinatorProtocol Implementation

extension UserProfileCoordinator: CoordinatorProtocol {
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .addProfile:
            break
        case .editProfile:
            break
        }
    }
}

// MARK: - Coordinate Implementation

extension UserProfileCoordinator: Coordinate {
    /// Screen representation type.
    enum Screen {
        case addProfile
        case editProfile
    }
    
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .addProfile:
            break
        case .editProfile:
            break
        }
        
        deploy(screen)
    }
}

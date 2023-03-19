//
//  AccountViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - AccountViewCoordinator Type

final class AccountViewCoordinator {
    var viewController: AccountViewController?
}

// MARK: - Coordinate Implementation

extension AccountViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case account
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {}
}

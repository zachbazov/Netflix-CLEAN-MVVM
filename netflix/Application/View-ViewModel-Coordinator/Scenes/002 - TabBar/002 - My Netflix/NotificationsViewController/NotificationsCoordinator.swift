//
//  NotificationsCoordinator.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import Foundation

// MARK: - NotificationsCoordinator Type

final class NotificationsCoordinator {
    var viewController: NotificationsViewController?
}

// MARK: - Coordinator Implementation

extension NotificationsCoordinator: Coordinator {
    enum Screen {
        case notifications
    }
    
    func coordinate(to screen: Screen) {
        
    }
}

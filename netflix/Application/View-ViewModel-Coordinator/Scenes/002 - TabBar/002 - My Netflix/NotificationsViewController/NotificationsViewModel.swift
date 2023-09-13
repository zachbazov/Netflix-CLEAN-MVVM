//
//  NotificationsViewModel.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import Foundation

// MARK: - NotificationsViewModel Type

final class NotificationsViewModel {
    var coordinator: NotificationsCoordinator?
}

// MARK: - ViewModel Implementation

extension NotificationsViewModel: ViewModel {}

// MARK: - CoordinatorAssiganble Implementation

extension NotificationsViewModel: CoordinatorAssignable {}

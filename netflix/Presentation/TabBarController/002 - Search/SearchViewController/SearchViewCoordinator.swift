//
//  SearchViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

// MARK: - SearchViewCoordinator Type

final class SearchViewCoordinator {
    var viewController: SearchViewController?
}

// MARK: - Coordinate Implementation

extension SearchViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case search
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func deploy(screen: Screen) {}
}

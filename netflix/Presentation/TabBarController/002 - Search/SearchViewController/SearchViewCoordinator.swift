//
//  SearchViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

final class SearchViewCoordinator {
    var viewController: SearchViewController?
}

extension SearchViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case search
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func showScreen(_ screen: Screen) {}
}

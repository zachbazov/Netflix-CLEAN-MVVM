//
//  FastLaughsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 28/02/2023.
//

import Foundation

// MARK: - FastLaughsViewCoordinator Type

final class FastLaughsViewCoordinator {
    var viewController: FastLaughsViewController?
}

// MARK: - Coordinator Implementation

extension FastLaughsViewCoordinator: Coordinator {
    enum Screen {
        case fastLaughs
    }
    
    func coordinate(to screen: Screen) {}
}

//
//  SearchViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

final class SearchViewCoordinator: Coordinate {
    enum Screen {
        case search
    }
    
    var viewController: SearchViewController?
    
    func showScreen(_ screen: Screen) {}
}

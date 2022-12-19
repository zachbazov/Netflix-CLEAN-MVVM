//
//  NewsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

final class NewsViewCoordinator: Coordinate {
    enum Screen {
        case news
    }
    
    var viewController: NewsViewController?
    
    func showScreen(_ screen: Screen) {}
}

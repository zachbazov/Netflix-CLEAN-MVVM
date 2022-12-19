//
//  DownloadsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import Foundation

final class DownloadsViewCoordinator: Coordinate {
    enum Screen {
        case downloads
    }
    
    var viewController: DownloadsViewController?
    
    func showScreen(_ screen: Screen) {}
}

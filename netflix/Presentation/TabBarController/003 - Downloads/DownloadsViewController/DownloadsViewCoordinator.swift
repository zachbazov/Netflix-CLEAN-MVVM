//
//  DownloadsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import Foundation

final class DownloadsViewCoordinator {
    var viewController: DownloadsViewController?
}

extension DownloadsViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case downloads
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func showScreen(_ screen: Screen) {}
}

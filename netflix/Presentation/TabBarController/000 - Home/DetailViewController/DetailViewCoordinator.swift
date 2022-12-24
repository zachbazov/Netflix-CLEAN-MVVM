//
//  DetailViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

final class DetailViewCoordinator {
    weak var viewController: DetailViewController?
    var media: Media?
    /// Create a new detail controller upon existed detail controller.
    /// - Parameter media: Corresponding media object.
    func allocateDetailController() {
        let navigation = viewController?.navigationController
        let controller = DetailViewController()
        let viewModel = viewController?.viewModel
        /// Stop playing the player.
        viewController?.previewView?.mediaPlayerView?.stopPlayer()
        /// Deallocate the current controller.
        viewController = nil
        /// Allocate the new controller.
        controller.viewModel = viewModel
        /// Depend on the new media object.
        controller.viewModel.media = media!
        viewController = controller
        /// Reallocate the navigation stack.
        navigation?.setViewControllers([controller], animated: true)
    }
}

extension DetailViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case detail
    }
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func showScreen(_ screen: Screen) {
        if case .detail = screen { allocateDetailController() }
    }
}

//
//  DetailViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    var media: Media? { get }
    
    func createDetailController()
}

// MARK: - DetailViewCoordinator Type

final class DetailViewCoordinator {
    weak var viewController: DetailViewController?
    
    var media: Media?
}

// MARK: - CoordinatorProtocol Implementation

extension DetailViewCoordinator: CoordinatorProtocol {
    /// Create a new detail controller upon existed detail controller.
    /// - Parameter media: Corresponding media object.
    func createDetailController() {
        let navigation = viewController?.navigationController
        let controller = DetailViewController()
        let viewModel = viewController?.viewModel
        // Stop playing the player.
        if let mediaPlayerView = viewController?.previewView?.mediaPlayerView {
            mediaPlayerView.delegate?.playerDidStop(mediaPlayerView.mediaPlayer)
        }
        // Deallocate the current controller.
        viewController = nil
        navigation?.viewControllers.removeAll()
        // Allocate the new controller.
        controller.viewModel = viewModel
        controller.viewModel.isRotated = false
        controller.viewModel.orientation.orientation = false ? .landscapeLeft : .portrait
        // Depend on the new media object.
        controller.viewModel.media = media!
        viewController = controller
        // Reallocate the navigation stack.
        navigation?.pushViewController(controller, animated: true)
    }
}

// MARK: - Coordinate Implementation

extension DetailViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case detail
    }
    
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .detail: createDetailController()
        }
    }
}

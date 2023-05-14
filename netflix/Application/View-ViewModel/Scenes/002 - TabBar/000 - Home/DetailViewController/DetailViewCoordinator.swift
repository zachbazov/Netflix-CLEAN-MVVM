//
//  DetailViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    func createDetailController()
}

// MARK: - DetailViewCoordinator Type

final class DetailViewCoordinator {
    weak var viewController: DetailViewController?
}

// MARK: - CoordinatorProtocol Implementation

extension DetailViewCoordinator: CoordinatorProtocol {
    /// Create a new detail controller upon existed detail controller.
    /// - Parameter media: Corresponding media object.
    func createDetailController() {
        guard let navigation = viewController?.navigationController else { return }
        
        let controller = DetailViewController()
        let viewModel = viewController?.viewModel
        
        if let mediaPlayerView = viewController?.previewView?.mediaPlayerView {
            mediaPlayerView.delegate?.playerDidStop(mediaPlayerView.mediaPlayer)
        }
        
        viewController = nil
        navigation.viewControllers.removeAll()
        
        controller.viewModel = viewModel
        controller.viewModel.isRotated = false
        controller.viewModel.orientation.orientation = false ? .landscapeLeft : .portrait
        
        viewController = controller
        
        navigation.pushViewController(controller, animated: true)
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

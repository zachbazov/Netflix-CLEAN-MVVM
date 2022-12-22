//
//  HomeViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

private protocol HomeCoordinable {
    func allocateDetailController()
}

final class HomeViewCoordinator {
    var viewController: HomeViewController?
    var section: Section?
    var media: Media?
    var shouldScreenRotate: Bool = false
}

extension HomeViewCoordinator: HomeCoordinable {
    func allocateDetailController() {
        guard let section = section, let media = media else { return }
        /// Allocate the controller and it's dependencies.
        let controller = DetailViewController()
        let homeViewModel = viewController!.viewModel!
        let viewModel = DetailViewModel(section: section, media: media, with: homeViewModel)
        /// Allocate controller dependencies.
        controller.viewModel = viewModel
        controller.viewModel.coordinator = DetailViewCoordinator()
        controller.viewModel.coordinator?.viewController = controller
        controller.viewModel.isRotated = shouldScreenRotate
        /// Wrap the controller with a navigation controller.
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        /// Present the navigation controller.
        viewController?.present(navigation, animated: true)
    }
}

extension HomeViewCoordinator: Coordinate {
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

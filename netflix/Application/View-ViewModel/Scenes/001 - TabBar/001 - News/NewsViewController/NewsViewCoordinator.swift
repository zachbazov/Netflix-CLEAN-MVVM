//
//  NewsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - NewsCoordinable Protocol

private protocol NewsCoordinable {
    func allocateDetailController()
}

// MARK: - NewsViewCoordinator Type

final class NewsViewCoordinator {
    var viewController: NewsViewController?
    var section: Section?
    var media: Media?
    var shouldScreenRotate: Bool = false
}

// MARK: - NewsCoordinable Implementation

extension NewsViewCoordinator: NewsCoordinable {
    fileprivate func allocateDetailController() {
        guard let section = section, let media = media else { return }
        /// An `HomeViewModel` reference is needed to gain access to the sections data.
        let homeNavigation = Application.app.sceneCoordinator.tabCoordinator.home!
        /// Extract home's view model reference.
        let homeController = homeNavigation.viewControllers.first! as! HomeViewController
        let homeViewModel = homeController.viewModel!
        /// Allocate the detail controller and it's dependencies.
        let controller = DetailViewController()
        let viewModel = DetailViewModel(section: section, media: media, with: homeViewModel)
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

// MARK: - Coordinate Implementation

extension NewsViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case detail
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        if case .detail = screen { allocateDetailController() }
    }
}

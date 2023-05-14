//
//  NewsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    var section: Section? { get }
    var media: Media? { get }
    var shouldScreenRotate: Bool { get }
    
    func createDetailController()
}

// MARK: - NewsViewCoordinator Type

final class NewsViewCoordinator {
    var viewController: NewsViewController?
    
    var section: Section?
    var media: Media?
    var shouldScreenRotate: Bool = false
}

// MARK: - CoordinatorProtocol Implementation

extension NewsViewCoordinator: CoordinatorProtocol {
    fileprivate func createDetailController() {
        guard let section = section, let media = media else { return }
        
        guard let homeController = Application.app.coordinator.tabCoordinator.viewController?.homeViewController,
              let homeViewModel = homeController.viewModel
        else { return }
        
        let controller = DetailViewController()
//        let viewModel = DetailViewModel(section: section, media: media, with: homeViewModel)
//        controller.viewModel = viewModel
//        controller.viewModel.coordinator = DetailViewCoordinator()
//        controller.viewModel.coordinator?.viewController = controller
//        controller.viewModel.isRotated = shouldScreenRotate
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        
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
        switch screen {
        case .detail: createDetailController()
        }
    }
}

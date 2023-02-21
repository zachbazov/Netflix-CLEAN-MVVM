//
//  HomeViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorInput {
    func deploy(_ screen: HomeViewCoordinator.Screen)
}

private protocol CoordinatorOutput {
    var navigationController: UINavigationController? { get }
    var section: Section? { get }
    var media: Media? { get }
    var shouldScreenRotate: Bool { get }
    
    func createNavigationController() -> UINavigationController?
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - HomeViewCoordinator Type

final class HomeViewCoordinator {
    var viewController: HomeViewController?
    
    fileprivate weak var navigationController: UINavigationController?
    
    var section: Section?
    var media: Media?
    var shouldScreenRotate = false
}

// MARK: - CoordinatorProtocol Implementation

extension HomeViewCoordinator: CoordinatorProtocol {
    func createNavigationController() -> UINavigationController? {
        guard let section = section, let media = media else { return nil }
        // Allocate the controller and it's dependencies.
        let controller = DetailViewController()
        let homeViewModel = viewController!.viewModel!
        let viewModel = DetailViewModel(section: section, media: media, with: homeViewModel)
        // Allocate controller dependencies.
        controller.viewModel = viewModel
        controller.viewModel.coordinator = DetailViewCoordinator()
        controller.viewModel.coordinator?.viewController = controller
        controller.viewModel.isRotated = shouldScreenRotate
        // Wrap the controller with a navigation controller.
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        return navigation
    }
    
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .detail:
            guard let navigationController = navigationController else { return }
            viewController?.present(navigationController, animated: true)
        }
    }
}

// MARK: - Coordinate Implementation

extension HomeViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case detail
    }
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .detail: navigationController = createNavigationController()
        }
        
        deploy(screen)
    }
}

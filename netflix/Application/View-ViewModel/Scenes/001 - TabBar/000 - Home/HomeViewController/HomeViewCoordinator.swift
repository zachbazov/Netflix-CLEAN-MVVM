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
    var detail: UINavigationController? { get }
    var section: Section? { get }
    var media: Media? { get }
    var shouldScreenRotate: Bool { get }
    
    func createDetailNavigationController() -> UINavigationController?
    func createSearchNavigationController() -> UINavigationController
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - HomeViewCoordinator Type

final class HomeViewCoordinator {
    var viewController: HomeViewController?
    
    fileprivate weak var detail: UINavigationController?
    weak var search: UINavigationController!
    
    var section: Section?
    var media: Media?
    var shouldScreenRotate = false
}

// MARK: - CoordinatorProtocol Implementation

extension HomeViewCoordinator: CoordinatorProtocol {
    fileprivate func createDetailNavigationController() -> UINavigationController? {
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
        controller.viewModel.orientation.orientation = shouldScreenRotate ? .landscapeLeft : .portrait
        // Wrap the controller with a navigation controller.
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.view.backgroundColor = .black
        return navigation
    }
    
    fileprivate func createSearchNavigationController() -> UINavigationController {
        let coordinator = SearchViewCoordinator()
        let viewModel = SearchViewModel()
        let controller = SearchViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.search.rawValue
        return navigation
    }
    
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .detail:
            guard let navigationController = detail else { return }
            viewController?.present(navigationController, animated: true)
        case .search:
            viewController!.add(child: search, container: viewController!.view)
            
            let searchViewController = search.viewControllers.first! as! SearchViewController
            searchViewController.present()
        }
    }
}

// MARK: - Coordinate Implementation

extension HomeViewCoordinator: Coordinate {
    /// View representation type.
    enum Screen: Int {
        case detail
        case search
    }
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .detail: detail = createDetailNavigationController()
        case .search: search = createSearchNavigationController()
        }
        
        deploy(screen)
    }
}

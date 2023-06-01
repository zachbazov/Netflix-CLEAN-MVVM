//
//  NewsViewCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    func createDetailController()
}

// MARK: - NewsViewCoordinator Type

final class NewsViewCoordinator {
    var viewController: NewsViewController?
    
    deinit {
        viewController?.viewModel = nil
        viewController?.removeFromParent()
        viewController = nil
    }
}

// MARK: - CoordinatorProtocol Implementation

extension NewsViewCoordinator: CoordinatorProtocol {
    fileprivate func createDetailController() {
        guard let viewModel = viewController?.viewModel,
              let section = viewModel.section,
              let media = viewModel.media
        else { return }
        
        let coordinator = DetailViewCoordinator()
        let controller = DetailViewController()
        let detailViewModel = DetailViewModel()
        
        controller.viewModel = detailViewModel
        controller.viewModel.media = media
        controller.viewModel.section = section
        controller.viewModel.isRotated = false
        coordinator.viewController = controller
        detailViewModel.coordinator = coordinator
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.view.setBackgroundColor(.black)
        
        viewController?.present(navigation, animated: true)
    }
}

// MARK: - Coordinator Implementation

extension NewsViewCoordinator: Coordinator {
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

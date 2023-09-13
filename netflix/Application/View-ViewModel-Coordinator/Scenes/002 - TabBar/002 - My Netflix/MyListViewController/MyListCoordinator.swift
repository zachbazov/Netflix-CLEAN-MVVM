//
//  MyListCoordinator.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import UIKit

// MARK: - MyListCoordinator Type

final class MyListCoordinator {
    var viewController: MyListViewController?
    
    weak var detail: UINavigationController?
    
    deinit {
        removeViewControllers()
        
        detail = nil
        
        viewController?.viewModel?.coordinator = nil
        viewController?.viewModel = nil
        viewController?.removeFromParent()
        viewController = nil
    }
    
    func removeViewControllers() {
        let detailController = detail?.viewControllers.first as? DetailViewController
        
        detailController?.viewDidDeallocate()
    }
}

// MARK: - Coordinator Implementation

extension MyListCoordinator: Coordinator {
    enum Screen: Int {
        case myList
        case detail
    }
    
    func coordinate(to screen: Screen) {
        switch screen {
        case .myList:
            break
        case .detail:
            detail = createDetailNavigationController()
            
            guard let navigation = detail else { return }
            viewController?.present(navigation, animated: true)
        }
    }
}

// MARK: - Private Implementation

extension MyListCoordinator {
    private func createDetailNavigationController() -> UINavigationController {
        let coordinator = DetailViewCoordinator()
        let viewModel = DetailViewModel()
        let controller = DetailViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.detail.rawValue
        return navigation
    }
}

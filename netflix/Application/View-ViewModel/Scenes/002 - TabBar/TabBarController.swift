//
//  TabBarController.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import UIKit

// MARK: - TabBarController Type

final class TabBarController: TabController {
    var viewModel: TabBarViewModel!
    
    var homeViewController: HomeViewController! {
        guard let coordinator = viewModel.coordinator,
              let controller = coordinator.home.viewControllers.first as? HomeViewController
        else { fatalError("Unexpected controller \(HomeViewController.self) value.") }
        return controller
    }
    
    var newsViewController: NewsViewController! {
        guard let coordinator = viewModel.coordinator,
              let controller = coordinator.news.viewControllers.first as? NewsViewController
        else { fatalError("Unexpected controller \(NewsViewController.self) value.") }
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidConfigure()
    }
}

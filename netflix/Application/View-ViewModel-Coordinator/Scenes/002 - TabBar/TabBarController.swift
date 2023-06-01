//
//  TabBarController.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import UIKit

// MARK: - TabBarController Type

final class TabBarController: UITabBarController, TabController {
    var viewModel: TabBarViewModel!
    
    deinit {
        viewModel?.coordinator = nil
        viewModel = nil
        
        viewControllers?.removeAll()
        removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidConfigure()
        
        delegate = self
    }
    
    func viewDidConfigure() {
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
    }
}

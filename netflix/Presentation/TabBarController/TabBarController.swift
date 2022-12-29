//
//  TabBarController.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import UIKit

// MARK: - TabBarController Type

final class TabBarController: UITabBarController, View {
    
    // MARK: Properties
    
    var viewModel: TabBarViewModel!
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
}

// MARK: - UI Setup

extension TabBarController {
    private func setupUI() {
        tabBar.barStyle = .black
        tabBar.isTranslucent = false
    }
}

//
//  TabController.swift
//  netflix
//
//  Created by Zach Bazov on 16/02/2023.
//

import UIKit

// MARK: - TabController Type

class TabController: UITabBarController {
    func viewDidConfigure() {
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
    }
}

//
//  NavigationController.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - NavigationController Type

class NavigationController: UINavigationController {
    var isHidden: Bool {
        get { return isNavigationBarHidden }
        set { setNavigationBarHidden(newValue, animated: false) }
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension NavigationController {
    private func setupSubviews() {
        modalPresentationStyle = .fullScreen
        isHidden = false
        
        navigationBar.prefersLargeTitles = false
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
    }
}

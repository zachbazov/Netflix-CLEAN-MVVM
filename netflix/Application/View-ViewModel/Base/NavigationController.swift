//
//  NavigationController.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - NavigationControllerStyling Type

protocol NavigationControllerStyling {
    func didConfigureTitleView(withAssetNamed asset: String)
}

// MARK: - NavigationProtocol Type

private protocol NavigationProtocol {
    var isHidden: Bool { get }
    
    func viewDidConfigure()
}

// MARK: - NavigationController Type

class NavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.viewDidConfigure()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

// MARK: - NavigationProtocol Implementation

extension NavigationController: NavigationProtocol {
    var isHidden: Bool {
        get { return isNavigationBarHidden }
        set { setNavigationBarHidden(newValue, animated: false) }
    }
    
    func viewDidConfigure() {
        modalPresentationStyle = .fullScreen
        isHidden = false
        
        navigationBar.prefersLargeTitles = false
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
    }
}

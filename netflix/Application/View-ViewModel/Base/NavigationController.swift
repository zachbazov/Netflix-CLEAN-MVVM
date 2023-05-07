//
//  NavigationController.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - NavigationControllerStyling Type

protocol NavigationControllerStyling {
    func titleViewWillConfigure(withAssetNamed asset: String)
}

// MARK: - NavigationProtocol Type

private protocol NavigationProtocol {
    var isHidden: Bool { get }
    
    func viewWillConfigure()
}

// MARK: - NavigationController Type

class NavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.viewWillConfigure()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

// MARK: - NavigationProtocol Implementation

extension NavigationController: NavigationProtocol {
    var isHidden: Bool {
        get { return isNavigationBarHidden }
        set { setNavigationBarHidden(newValue, animated: false) }
    }
    
    func viewWillConfigure() {
        modalPresentationStyle = .fullScreen
        isHidden = false
        
        navigationBar.prefersLargeTitles = false
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
    }
}

//
//  NavigationController.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - NavigatableController Type

private protocol NavigatableController: UINavigationController {
    var isHidden: Bool { get set }
    
    func viewWillConfigure()
}

// MARK: - NavigationController Type

final class NavigationController: UINavigationController {
    var isHidden: Bool {
        get { return isNavigationBarHidden }
        set { setNavigationBarHidden(newValue, animated: false) }
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.viewWillConfigure()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
    }
}

// MARK: - NavigatableController Implementation

extension NavigationController: NavigatableController {
    func viewWillConfigure() {
        modalPresentationStyle = .fullScreen
        isHidden = false
        
        navigationBar.prefersLargeTitles = false
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
    }
}

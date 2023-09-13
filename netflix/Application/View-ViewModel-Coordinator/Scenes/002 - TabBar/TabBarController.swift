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
        viewDidDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidConfigure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewDidBindObservers()
        viewModel?.getSelectedProfile(nil)
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension TabBarController {
    func viewDidConfigure() {
        delegate = self
        
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
    }
    
    func viewDidDeallocate() {
        viewDidUnbindObservers()
        
        viewModel?.coordinator = nil
        viewModel = nil
        
        delegate = nil
        
        viewControllers?.removeAll()
        removeFromParent()
    }
}

// MARK: - ViewObservable Implementation

extension TabBarController {
    func viewDidBindObservers() {
        viewModel?.selectedProfile.observe(on: self) { [weak self] profile in
            guard let self = self, let profile = profile else { return }
            
            self.updateUI(for: profile)
        }
    }
    
    func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.selectedProfile.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
}

// MARK: - UITabBarControllerDelegate Implementation

extension TabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let item = TabBarCoordinator.Screen(rawValue: item.tag) else { return }
        
        switch item {
        case .home:
            tabBar.barStyle = .black
            tabBar.isTranslucent = true
        case .news:
            tabBar.barStyle = .black
            tabBar.isTranslucent = true
        case .myNetflix:
            tabBar.barStyle = .black
            tabBar.isTranslucent = false
        }
    }
}

// MARK: - Private Implementation

extension TabBarController {
    private func updateUI(for profile: Profile) {
        let screen = TabBarCoordinator.Screen.myNetflix
        
        guard let item = self.tabBar.items?[screen.rawValue] else { return }
        
        let originImage = UIImage(named: profile.image)
        let resizeImage = originImage?.scale(newWidth: 24.0, cornerRadius: 2.0, borderWidth: 3.0)
        
        item.selectedImage = resizeImage?.withRenderingMode(.alwaysOriginal)
        item.image = resizeImage?.withRenderingMode(.alwaysOriginal)
    }
}

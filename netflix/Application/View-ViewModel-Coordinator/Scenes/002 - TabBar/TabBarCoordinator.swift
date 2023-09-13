//
//  TabBarCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - TabBarConfiguration Type

private struct TabBarConfiguration {
    /// Provide a tab bar item based on the screen type for a controller.
    /// - Parameters:
    ///   - screen: The screen type.
    ///   - controller: The controller to be applied on.
    func tabBarItem(for screen: TabBarCoordinator.Screen, with controller: UIViewController) {
        switch screen {
        case .home:
            homeTabItem(for: controller as! UINavigationController)
        case .news:
            newsTabItem(for: controller as! UINavigationController)
        case .myNetflix:
            myNetflixTabItem(for: controller as! UINavigationController)
        }
    }
    
    /// Create an Home tab bar item.
    /// - Parameter controller: Tab's root controller.
    private func homeTabItem(for controller: UINavigationController) {
        let title = Localization.TabBar.Coordinator().homeButton
        let systemImage = "house.fill"
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15.0)
        let image = UIImage(systemName: systemImage)?.whiteRendering(with: symbolConfiguration)
        let tag = TabBarCoordinator.Screen.home.rawValue
        let item = TabBarItem(title: title, image: image!, tag: tag, navigationBarHidden: true)
        item.applyConfig(for: controller)
    }
    
    private func newsTabItem(for controller: UINavigationController) {
        let title = "News & Hot"
        let systemImage = "play.rectangle.on.rectangle"
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15.0)
        let image = UIImage(systemName: systemImage)?.whiteRendering(with: symbolConfiguration)
        let tag = TabBarCoordinator.Screen.news.rawValue
        let item = TabBarItem(title: title, image: image!, tag: tag, navigationBarHidden: true)
        item.applyConfig(for: controller)
    }
    
    private func myNetflixTabItem(for controller: UINavigationController) {
        let title = "My Netflix"
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15.0)
        let tag = TabBarCoordinator.Screen.myNetflix.rawValue
        let item = TabBarItem(title: title, image: nil, tag: tag)
        controller.tabBarController?.tabBar.barStyle = .default
        controller.tabBarController?.tabBar.isTranslucent = true
        item.applyConfig(for: controller)
    }
}

// MARK: - Configuration Item Type

extension TabBarConfiguration {
    /// Item representation type.
    private struct TabBarItem {
        let title: String
        var image: UIImage?
        let tag: Int
        var navigationBarHidden: Bool?
        
        /// Apply configuration a tab bar item.
        /// - Parameter controller: Receiver view controller.
        func applyConfig<T: UIViewController>(for controller: T) {
            let attributes = NSAttributedString.tabBarItemAttributes
            controller.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
            controller.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
            
            // In-case the receiver view controller wrapper is a navigation controller type.
            if let controller = controller as? UINavigationController {
                controller.setNavigationBarHidden(navigationBarHidden ?? true, animated: false)
            }
        }
    }
}

// MARK: - TabBarCoordinator Type

final class TabBarCoordinator {
    weak var viewController: TabBarController?
    
    fileprivate let configuration = TabBarConfiguration()
    
    lazy var home: UINavigationController? = createHomeController()
    lazy var news: UINavigationController? = createNewsController()
    lazy var myNetflix: UINavigationController? = createMyNetflixController()
    
    deinit {
        home = nil
        news = nil
        myNetflix = nil
        
        viewController?.viewModel?.coordinator = nil
        viewController?.viewModel = nil
        viewController?.viewControllers?.removeAll()
        viewController?.removeFromParent()
        viewController = nil
    }
    
    init() {
        Theme.applyAppearance()
    }
    
    func removeViewControllers() {
        let homeController = home?.viewControllers.first as? HomeViewController
        let newsController = news?.viewControllers.first as? NewsViewController
        let myNetflixController = myNetflix?.viewControllers.first as? MyNetflixViewController
        
        homeController?.viewWillDeallocate()
        newsController?.viewWillDeallocate()
        myNetflixController?.viewDidDeallocate()
    }
}

// MARK: -  Implementation

extension TabBarCoordinator {
    /// Allocate home view controller and it's dependencies.
    /// Reset after re-allocation if needed.
    /// - Returns: A wrapper navigation controller for the view controller.
    func createHomeController() -> UINavigationController {
        let coordinator = HomeViewCoordinator()
        let viewModel = HomeViewModel()
        let controller = HomeViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.tag = Screen.home.rawValue
        configuration.tabBarItem(for: .home, with: navigation)
        return navigation
    }
    
    func createNewsController() -> UINavigationController {
        let coordinator = NewsViewCoordinator()
        let viewModel = NewsViewModel()
        let controller = NewsViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.tag = Screen.news.rawValue
        configuration.tabBarItem(for: .news, with: navigation)
        return navigation
    }
    
    func createMyNetflixController() -> UINavigationController {
        let coordinator = MyNetflixCoordinator()
        let viewModel = MyNetflixViewModel()
        let controller = MyNetflixViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.navigationBar.tag = Screen.myNetflix.rawValue
        configuration.tabBarItem(for: .myNetflix, with: navigation)
        return navigation
    }
}

// MARK: - Coordinator Implementation

extension TabBarCoordinator: Coordinator {
    /// View representation type.
    enum Screen: Int {
        case home
        case news
        case myNetflix
    }
    
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        guard let home = home,
              let news = news,
              let myNetflix = myNetflix
        else { return }
        
        viewController?.viewControllers = [home, news, myNetflix]
        viewController?.selectedIndex = screen.rawValue
    }
}

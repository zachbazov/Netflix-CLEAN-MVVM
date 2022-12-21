//
//  TabBarCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

private protocol TabBarCoordinable {
    func allocateViewControllers()
    func homeDependencies() -> UINavigationController
    func newsDependencies() -> UINavigationController
    func searchDependencies() -> UINavigationController
    func downloadsDependencies() -> DownloadsViewController
}

private struct TabBarConfiguration {
    /// TabBar item data representation.
    private struct TabBarItem {
        let title: String
        let image: UIImage
        let tag: Int
        var navigationBarHidden: Bool?
        
        /// Apply configuration a tab bar item.
        /// - Parameter controller: Receiver view controller.
        func applyConfig<T: UIViewController>(for controller: T) {
            let attributes = NSAttributedString.tabBarItemAttributes
            controller.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
            controller.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
            /// In-case the receiver view controller wrapper is a navigation controller type.
            if let controller = controller as? UINavigationController {
                controller.setNavigationBarHidden(navigationBarHidden ?? true, animated: false)
            }
        }
    }
    /// Provide a tab bar item based on the screen type for a controller.
    /// - Parameters:
    ///   - screen: The screen type.
    ///   - controller: The controller to be applied on.
    func tabBarItem(for screen: TabBarCoordinator.Screen, with controller: UIViewController) {
        if case .home = screen { homeTabItem(for: controller as! UINavigationController) }
        else if case .news = screen { newsTabItem(for: controller as! UINavigationController) }
        else if case .search = screen { searchTabItem(for: controller as! UINavigationController) }
        else { downloadsTabItem(for: controller as! DownloadsViewController) }
    }
    /// Create an Home tab bar item.
    /// - Parameter controller: Tab's root controller.
    private func homeTabItem(for controller: UINavigationController) {
        let title = Localization.TabBar.Coordinator().homeButton
        let systemImage = "house.fill"
        let image = UIImage(systemName: systemImage)?.whiteRendering()
        let tag = TabBarCoordinator.Screen.home.rawValue
        let item = TabBarItem(title: title, image: image!, tag: tag, navigationBarHidden: true)
        item.applyConfig(for: controller)
    }
    
    private func newsTabItem(for controller: UINavigationController) {
        let title = "News & Hot"
        let systemImage = "play.rectangle.on.rectangle.fill"
        let image = UIImage(systemName: systemImage)?.whiteRendering()
        let tag = TabBarCoordinator.Screen.news.rawValue
        let item = TabBarItem(title: title, image: image!, tag: tag, navigationBarHidden: true)
        item.applyConfig(for: controller)
    }
    
    private func searchTabItem(for controller: UINavigationController) {
        let title = Localization.TabBar.Coordinator().searchButton
        let systemImage = "magnifyingglass"
        let image = UIImage(systemName: systemImage)?.whiteRendering()
        let tag = TabBarCoordinator.Screen.search.rawValue
        let item = TabBarItem(title: title, image: image!, tag: tag, navigationBarHidden: true)
        item.applyConfig(for: controller)
    }
    
    private func downloadsTabItem(for controller: DownloadsViewController) {
        let title = "Downloads"
        let systemImage = "arrow.down.circle.fill"
        let image = UIImage(systemName: systemImage)?.whiteRendering()
        let tag = TabBarCoordinator.Screen.downloads.rawValue
        let item = TabBarItem(title: title, image: image!, tag: tag)
        item.applyConfig(for: controller)
    }
}

final class TabBarCoordinator {
    weak var viewController: TabBarController?
    private let configuration = TabBarConfiguration()
    private(set) var home: UINavigationController!
    private var news: UINavigationController!
    private var search: UINavigationController!
    private var downloads: UIViewController!
    /// In-order to gain access to the home page,
    /// request the user credentials.
    func requestUserCredentials() {
        let viewModel = AuthViewModel()
        viewModel.cachedAuthorizationSession { [weak self] in self?.allocateViewControllers() }
    }
    /// Due to reallocation, certain data needs to be stored,
    /// in-order for the application flow flawlessly.
    func afterReallocationSettings(with viewModel: HomeViewModel) {
        updateHomeTableViewDataSourceState(with: viewModel)
    }
    /// Restating home's table view data source.
    /// - Parameter viewModel: Coordinating view model.
    private func updateHomeTableViewDataSourceState(with viewModel: HomeViewModel) {
        let tabViewModel = viewController?.viewModel
        /// Based on the navigation view state, set home's table view data source state accordingly.
        if tabViewModel?.homeNavigationState == .home {
            tabViewModel?.homeDataSourceState.value = .all
        } else if tabViewModel?.homeNavigationState == .tvShows {
            tabViewModel?.homeDataSourceState.value = .series
        } else if tabViewModel?.homeNavigationState == .movies {
            tabViewModel?.homeDataSourceState.value = .films
        } else {}
        /// Pass the table view data source state to home's view model.
        viewModel.tableViewState = tabViewModel?.homeDataSourceState.value
    }
}

extension TabBarCoordinator: TabBarCoordinable {
    /// Allocate and set view controllers for the tab controller.
    fileprivate func allocateViewControllers() {
        /// Home's navigation view controls the state of the table view data source.
        /// Hence, `home` property will be initialized every time the state changes.
        home = homeDependencies()
        /// One-time initialization is needed for the other scenes.
        if news == nil { news = newsDependencies() }
        if search == nil { search = searchDependencies() }
        if downloads == nil { downloads = downloadsDependencies() }
        /// Arranged view controllers for the tab controller.
        viewController?.viewControllers = [home, news, search, downloads]
    }
    /// Allocate home view controller and it's dependencies.
    /// Reset after re-allocation if needed.
    /// - Returns: A wrapper navigation controller for the view controller.
    fileprivate func homeDependencies() -> UINavigationController {
        let coordinator = HomeViewCoordinator()
        let viewModel = HomeViewModel()
        let controller = HomeViewController()
        /// In-case of reallocation, reset home's settings.
        afterReallocationSettings(with: viewModel)
        /// Allocate root's referencens.
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        controller.viewModel.coordinator?.viewController = controller
        coordinator.viewController = controller
        coordinator.viewController?.viewModel = viewModel
        /// Embed the view controller in a navigation controller.
        let navigation = UINavigationController(rootViewController: controller)
        /// Configure the tab bar item.
        configuration.tabBarItem(for: .home, with: navigation)
        return navigation
    }
    
    fileprivate func newsDependencies() -> UINavigationController {
        let coordinator = NewsViewCoordinator()
        let viewModel = NewsViewModel()
        let controller = NewsViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        configuration.tabBarItem(for: .news, with: navigation)
        return navigation
    }
    
    fileprivate func searchDependencies() -> UINavigationController {
        let coordinator = SearchViewCoordinator()
        let viewModel = SearchViewModel()
        let controller = SearchViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        configuration.tabBarItem(for: .search, with: navigation)
        return navigation
    }
    
    fileprivate func downloadsDependencies() -> DownloadsViewController {
        let coordinator = DownloadsViewCoordinator()
        let viewModel = DownloadsViewModel()
        let controller = DownloadsViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        configuration.tabBarItem(for: .downloads, with: controller)
        return controller
    }
}

extension TabBarCoordinator: Coordinate {
    /// View representation type.
    enum Screen: Int {
        case home       = 000
        case news       = 001
        case search     = 002
        case downloads  = 003
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func showScreen(_ screen: Screen) {
        if case .home = screen { allocateViewControllers() }
    }
}

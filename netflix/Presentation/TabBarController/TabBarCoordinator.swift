//
//  TabBarCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

final class TabBarCoordinator: Coordinate {
    enum Screen {
        case home
        case search
        case downloads
    }
    
    weak var viewController: TabBarController?
    
    private var home: UINavigationController!
    private var news: UINavigationController!
    private var search: UINavigationController!
    private var downloads: UIViewController!
    
    func showScreen(_ screen: Screen) {
        switch screen {
        case .home:
            createViewControllers(with: .home)
        default:
            break
        }
    }
    
    private func createViewControllers(with state: NavigationView.State? = nil) {
        home = homeNavigation(state)
        if news == nil { news = newsNavigation() }
        if search == nil { search = searchNavigation() }
        if downloads == nil { downloads = downloadsController() }
        
        viewController?.viewControllers = [home, news, search, downloads]
    }
}

extension TabBarCoordinator {
    private func homeNavigation(_ state: NavigationView.State?) -> UINavigationController {
        let coordinator = HomeViewCoordinator()
        let viewModel = HomeViewModel()
        let controller = HomeViewController()
        
        if state == .tvShows {
            viewController?.viewModel.homeDataSourceState.value = .series
        } else if state == .movies {
            viewController?.viewModel.homeDataSourceState.value = .films
        } else if state == .home {
            viewController?.viewModel.homeDataSourceState.value = .all
        } else {}
        
        viewModel.tableViewState = viewController?.viewModel.homeDataSourceState.value
        controller.viewModel = viewModel
        controller.viewModel.tableViewState = viewController?.viewModel.homeDataSourceState.value
        controller.viewModel.coordinator = coordinator
        controller.viewModel.coordinator?.viewController = controller
        coordinator.viewController = controller
        coordinator.viewController?.viewModel = viewModel
        
        let navigation = UINavigationController(rootViewController: controller)
        setupHomeTabItem(navigation)
        return navigation
    }
    
    private func setupHomeTabItem(_ controller: UINavigationController) {
        let title = Localization.TabBar.Coordinator().homeButton
        let image = UIImage(systemName: "house.fill")?.whiteRendering()
        controller.tabBarItem = UITabBarItem(title: title, image: image, tag: 0)
        controller.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0, weight: .bold)], for: .normal)
        
        controller.setNavigationBarHidden(true, animated: false)
    }
    
    func requestUserCredentials(_ state: NavigationView.State?) {
        let viewModel = AuthViewModel()
        
        viewModel.cachedAuthorizationSession { [weak self] in
            self?.createViewControllers(with: state)
        }
    }
    
    func terminateHomeViewController() {
        let tabBar = Application.current.rootCoordinator.window?.rootViewController as! TabBarController
        let homeNavigation = tabBar.viewControllers?.first! as! UINavigationController
        let homeViewController = homeNavigation.viewControllers.first! as? HomeViewController
        
        homeViewController?.navigationView?.navigationOverlayView?.tableView.removeFromSuperview()
        homeViewController?.navigationView?.navigationOverlayView?.removeFromSuperview()
        homeViewController?.navigationView?.navigationOverlayView = nil
        homeViewController?.navigationView?.removeFromSuperview()
        homeViewController?.navigationView = nil

        homeViewController?.browseOverlayView?.removeFromSuperview()
        homeViewController?.browseOverlayView = nil
        
        homeViewController?.viewModel?.myList?.removeObservers()
        homeViewController?.viewModel?.coordinator = nil
        homeViewController?.viewModel?.mediaTask = nil
        homeViewController?.viewModel?.sectionsTask = nil
        homeViewController?.viewModel?.tableViewState = nil
        homeViewController?.viewModel?.myList = nil
        homeViewController?.viewModel = nil

        homeViewController?.removeObservers()
        homeViewController?.removeFromParent()
    }
}

extension TabBarCoordinator {
    private func newsNavigation() -> UINavigationController {
        let coordinator = NewsViewCoordinator()
        let viewModel = NewsViewModel()
        let controller = NewsViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        setupNewsTabItem(for: navigation)
        return navigation
    }
    
    private func setupNewsTabItem(for controller: UINavigationController) {
        let title = "News & Hot"
        let image = UIImage(systemName: "play.rectangle.on.rectangle.fill")?.whiteRendering()
        
        controller.tabBarItem = UITabBarItem(title: title, image: image, tag: 1)
        controller.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0, weight: .bold)], for: .normal)
        
        controller.setNavigationBarHidden(true, animated: false)
    }
}

extension TabBarCoordinator {
    private func searchNavigation() -> UINavigationController {
        let coordinator = SearchViewCoordinator()
        let viewModel = SearchViewModel()
        let controller = SearchViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        setupSearchTabItem(for: navigation)
        return navigation
    }
    
    private func setupSearchTabItem(for controller: UINavigationController) {
        let title = Localization.TabBar.Coordinator().searchButton
        let image = UIImage(systemName: "magnifyingglass")?.whiteRendering()
        
        controller.tabBarItem = UITabBarItem(title: title, image: image, tag: 2)
        controller.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0, weight: .bold)], for: .normal)
        
        controller.setNavigationBarHidden(true, animated: false)
    }
}

extension TabBarCoordinator {
    private func downloadsController() -> DownloadsViewController {
        let coordinator = DownloadsViewCoordinator()
        let viewModel = DownloadsViewModel()
        let controller = DownloadsViewController()
        
        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller
        
        setupDownloadsTabItem(for: controller)
        return controller
    }
    
    private func setupDownloadsTabItem(for controller: DownloadsViewController) {
        let title = "Downloads"
        let image = UIImage(systemName: "arrow.down.circle.fill")?.whiteRendering()
        
        controller.tabBarItem = UITabBarItem(title: title, image: image, tag: 3)
        controller.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0, weight: .bold)], for: .normal)
    }
}

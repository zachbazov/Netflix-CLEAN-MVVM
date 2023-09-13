//
//  MyNetflixCoordinator.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import UIKit

// MARK: - MyNetflixCoordinator Type

final class MyNetflixCoordinator {
    var viewController: MyNetflixViewController?
    
    weak var search: UINavigationController?
    weak var notifications: UINavigationController?
    weak var downloads: UINavigationController?
    weak var myList: UINavigationController?
    weak var detail: UINavigationController?
    
    deinit {
        removeViewControllers()
        
        myList = nil
        downloads = nil
        notifications = nil
        search = nil
        detail = nil
        
        viewController?.viewModel?.coordinator = nil
        viewController?.viewModel = nil
        viewController?.removeFromParent()
        viewController = nil
    }
    
    func removeViewControllers() {
        let searchController = search?.viewControllers.first as? SearchViewController
        let notificationsController = notifications?.viewControllers.first as? NotificationsViewController
        let downloadsController = downloads?.viewControllers.first as? DownloadsViewController
        let myListController = myList?.viewControllers.first as? MyListViewController
        let detailController = detail?.viewControllers.first as? DetailViewController
        
        searchController?.viewDidDeallocate()
        notificationsController?.viewDidDeallocate()
        downloadsController?.viewDidDeallocate()
        myListController?.viewDidDeallocate()
        detailController?.viewDidDeallocate()
    }
}

// MARK: - Coordinator Implementation

extension MyNetflixCoordinator: Coordinator {
    enum Screen: Int {
        case myNetflix
        case notifications
        case downloads
        case myList
        case search
        case menu
        case detail
    }
    
    func coordinate(to screen: Screen) {
        switch screen {
        case .myNetflix:
            break
        case .notifications:
            notifications = createNotificationsController()
            
            guard let navigation = notifications else { return }
            viewController?.present(navigation, animated: true)
        case .downloads:
            downloads = createDownloadsController()
            
            guard let navigation = downloads else { return }
            viewController?.present(navigation, animated: true)
        case .myList:
//            guard let tabCoordinator = Application.app.coordinator.tabCoordinator else { return }
            
            myList = createMyListController()
            
            guard let navigation = myList else { return }
            viewController?.present(navigation, animated: true)
            
//            guard let navigation = myList,
//                  let controller = navigation.viewControllers.first as? MyListViewController
//            else { return }
//            navigation.setNavigationBarHidden(false, animated: false)
//            tabCoordinator.myNetflix?.pushViewController(controller, animated: true)
        case .search:
            search = createSearchNavigationController()
            
            guard let navigation = search, let view = viewController?.view else { return }
            viewController?.add(child: navigation, container: view)
            
            guard let controller = navigation.viewControllers.first as? SearchViewController else { return }
            controller.viewWillAnimateAppearance()
        case .menu:
            break
        case .detail:
            detail = createDetailNavigationController()
            
            guard let navigation = detail else { return }
            viewController?.present(navigation, animated: true)
        }
    }
    
    private func createSearchNavigationController() -> UINavigationController {
        let coordinator = SearchViewCoordinator()
        let viewModel = SearchViewModel()
        let controller = SearchViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.search.rawValue
        return navigation
    }
    
    func createNotificationsController() -> UINavigationController {
        let coordinator = NotificationsCoordinator()
        let viewModel = NotificationsViewModel()
        let controller = NotificationsViewController()

        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller

        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.notifications.rawValue
        return navigation
    }
    
    func createDownloadsController() -> UINavigationController {
        let coordinator = DownloadsViewCoordinator()
        let viewModel = DownloadsViewModel()
        let controller = DownloadsViewController()

        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller

        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.downloads.rawValue
        return navigation
    }
    
    func createMyListController() -> UINavigationController {
        let coordinator = MyListCoordinator()
        let viewModel = MyListViewModel()
        let controller = MyListViewController()

        controller.viewModel = viewModel
        controller.viewModel.coordinator = coordinator
        coordinator.viewController = controller

        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(false, animated: false)
        navigation.navigationBar.tag = Screen.myList.rawValue
        return navigation
    }
    
    private func createDetailNavigationController() -> UINavigationController {
        let coordinator = DetailViewCoordinator()
        let viewModel = DetailViewModel()
        let controller = DetailViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.navigationBar.tag = Screen.detail.rawValue
        return navigation
    }
}

/*
 //
 //  MyNetflixCoordinator.swift
 //  netflix
 //
 //  Created by Developer on 09/09/2023.
 //

 import UIKit

 // MARK: - MyNetflixCoordinator Type

 final class MyNetflixCoordinator {
     var viewController: MyNetflixViewController?
     
     weak var search: UINavigationController?
     weak var notifications: UINavigationController?
     weak var downloads: UINavigationController?
     weak var myList: UINavigationController?
     weak var detail: UINavigationController?
     
     deinit {
         removeViewControllers()
         
         myList = nil
         downloads = nil
         notifications = nil
         search = nil
         detail = nil
         
         viewController?.viewModel?.coordinator = nil
         viewController?.viewModel = nil
         viewController?.removeFromParent()
         viewController = nil
     }
     
     func removeViewControllers() {
         let searchController = search?.viewControllers.first as? SearchViewController
         let notificationsController = notifications?.viewControllers.first as? NotificationsViewController
         let downloadsController = downloads?.viewControllers.first as? DownloadsViewController
         let myListController = myList?.viewControllers.first as? MyListViewController
         let detailController = detail?.viewControllers.first as? DetailViewController
         
         searchController?.viewDidDeallocate()
         notificationsController?.viewDidDeallocate()
         downloadsController?.viewDidDeallocate()
         myListController?.viewDidDeallocate()
         detailController?.viewDidDeallocate()
     }
 }

 // MARK: - Coordinator Implementation

 extension MyNetflixCoordinator: Coordinator {
     enum Screen: Int {
         case myNetflix
         case notifications
         case downloads
         case myList
         case search
         case menu
         case detail
     }
     
     func coordinate(to screen: Screen) {
         switch screen {
         case .myNetflix:
             break
         case .notifications:
             notifications = createNotificationsController()
             
             guard let navigation = notifications else { return }
             viewController?.present(navigation, animated: true)
         case .downloads:
             downloads = createDownloadsController()
             
             guard let navigation = downloads else { return }
             viewController?.present(navigation, animated: true)
         case .myList:
             guard let tabCoordinator = Application.app.coordinator.tabCoordinator else { return }
             
             myList = createMyListController()
             
             guard let navigation = myList,
                   let controller = navigation.viewControllers.first as? MyListViewController
             else { return }
             navigation.setNavigationBarHidden(false, animated: false)
             tabCoordinator.myNetflix?.pushViewController(controller, animated: true)
         case .search:
             search = createSearchNavigationController()
             
             guard let navigation = search, let view = viewController?.view else { return }
             viewController?.add(child: navigation, container: view)
             
             guard let controller = navigation.viewControllers.first as? SearchViewController else { return }
             controller.viewWillAnimateAppearance()
         case .menu:
             break
         case .detail:
             detail = createDetailNavigationController()
             
             guard let navigation = detail else { return }
             viewController?.present(navigation, animated: true)
         }
     }
     
     private func createSearchNavigationController() -> UINavigationController {
         let coordinator = SearchViewCoordinator()
         let viewModel = SearchViewModel()
         let controller = SearchViewController()
         
         controller.viewModel = viewModel
         controller.viewModel?.coordinator = coordinator
         coordinator.viewController = controller
         
         let navigation = UINavigationController(rootViewController: controller)
         navigation.setNavigationBarHidden(true, animated: false)
         navigation.navigationBar.tag = Screen.search.rawValue
         return navigation
     }
     
     func createNotificationsController() -> UINavigationController {
         let coordinator = NotificationsCoordinator()
         let viewModel = NotificationsViewModel()
         let controller = NotificationsViewController()

         controller.viewModel = viewModel
         controller.viewModel.coordinator = coordinator
         coordinator.viewController = controller

         let navigation = UINavigationController(rootViewController: controller)
         navigation.setNavigationBarHidden(true, animated: false)
         navigation.navigationBar.tag = Screen.notifications.rawValue
         return navigation
     }
     
     func createDownloadsController() -> UINavigationController {
         let coordinator = DownloadsViewCoordinator()
         let viewModel = DownloadsViewModel()
         let controller = DownloadsViewController()

         controller.viewModel = viewModel
         controller.viewModel.coordinator = coordinator
         coordinator.viewController = controller

         let navigation = UINavigationController(rootViewController: controller)
         navigation.setNavigationBarHidden(true, animated: false)
         navigation.navigationBar.tag = Screen.downloads.rawValue
         return navigation
     }
     
     func createMyListController() -> UINavigationController {
         let coordinator = MyListCoordinator()
         let viewModel = MyListViewModel()
         let controller = MyListViewController()

         controller.viewModel = viewModel
         controller.viewModel.coordinator = coordinator
         coordinator.viewController = controller

         let navigation = UINavigationController(rootViewController: controller)
         navigation.setNavigationBarHidden(false, animated: false)
         navigation.navigationBar.tag = Screen.myList.rawValue
         return navigation
     }
     
     private func createDetailNavigationController() -> UINavigationController {
         let coordinator = DetailViewCoordinator()
         let viewModel = DetailViewModel()
         let controller = DetailViewController()
         
         controller.viewModel = viewModel
         controller.viewModel?.coordinator = coordinator
         coordinator.viewController = controller
         
         let navigation = UINavigationController(rootViewController: controller)
         navigation.setNavigationBarHidden(true, animated: false)
         navigation.navigationBar.tag = Screen.detail.rawValue
         return navigation
     }
 }

 */

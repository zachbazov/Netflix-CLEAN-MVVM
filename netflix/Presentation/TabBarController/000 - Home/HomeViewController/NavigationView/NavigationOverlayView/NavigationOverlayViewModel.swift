//
//  NavigationOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import Foundation

// MARK: - NavigationOverlayViewModel Type

final class NavigationOverlayViewModel {
    
    // MARK: Properties
    
    private let coordinator: HomeViewCoordinator
    let isPresented: Observable<Bool> = Observable(false)
    let items: Observable<[Valuable]> = Observable([])
    private var state: NavigationOverlayTableViewDataSource.State = .main
    let numberOfSections: Int = 1
    private var latestState: NavigationView.State = .home
    private var hasHomeExpanded = false
    private var hasTvExpanded = false
    private var hasMoviesExpanded = false
    
    // MARK: Initializer
    
    /// Create a navigation overlay view view model object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - Methods

extension NavigationOverlayViewModel {
    /// Presentation of the view.
    func isPresentedDidChange() {
        if case true = isPresented.value { itemsDidChange() }
        
        animatePresentation()
    }
    /// Release data source changes and center the content.
    func dataSourceDidChange() {
        guard let navigationOverlayView = coordinator.viewController?.navigationView?.navigationOverlayView else {
            return
        }
        
        let tableView = navigationOverlayView.tableView
        /// In-case there is no allocated delegate.
        if tableView.delegate == nil {
            tableView.delegate = navigationOverlayView.dataSource
            tableView.dataSource = navigationOverlayView.dataSource
        }
        /// Release changes.
        tableView.reloadData()
        /// Center the content.
        tableView.centerVertically(on: navigationOverlayView)
    }
    /// Change `items` value based on the data source `state` value.
    private func itemsDidChange() {
        if case .main = state { items.value = NavigationView.State.allCases[3...5].toArray() }
        else if case .genres = state { items.value = NavigationOverlayView.Category.allCases }
        else { items.value = [] }
    }
    /// Animate the presentation of the view.
    private func animatePresentation() {
        guard let navigationOverlayView = coordinator.viewController?.navigationView?.navigationOverlayView else {
            return
        }
        
        navigationOverlayView.animateUsingSpring(
            withDuration: 0.5,
            withDamping: 1.0,
            initialSpringVelocity: 0.5,
            animations: { [weak self] in
                guard let self = self else { return }
                navigationOverlayView.alpha = self.isPresented.value ? 1.0 : 0.0
                navigationOverlayView.tableView.alpha = self.isPresented.value ? 1.0 : 0.0
                navigationOverlayView.footerView.alpha = self.isPresented.value ? 1.0 : 0.0
                navigationOverlayView.tabBar.alpha = self.isPresented.value ? 0.0 : 1.0
            },
            completion: { [weak self] done in
                guard let self = self else { return }
                /// In-case the overlay has been closed and animation is done.
                if !self.isPresented.value && done {
                    navigationOverlayView.tableView.delegate = nil
                    navigationOverlayView.tableView.dataSource = nil
                }
            })
    }
    
    func navigationViewStateDidChange(_ state: NavigationView.State) {
        guard let homeViewController = coordinator.viewController,
              let homeViewModel = homeViewController.viewModel,
              let navigationView = homeViewController.navigationView,
              let browseOverlayView = coordinator.viewController!.browseOverlayView else {
            return
        }
        
        switch state {
        case .home:
            // In-case the user already interacting with browse's overlay, and wants to dismiss it.
            if !isPresented.value && browseOverlayView.viewModel.isPresented {
                // Set the navigation settings by the latest state stored value.
                hasHomeExpanded = false
                hasTvExpanded = latestState == .tvShows ? true : false
                hasMoviesExpanded = latestState == .movies ? true : false
                // Restore the navigation view state.
                if case .tvShows = latestState {
                    navigationView.viewModel.stateDidChange(.tvShows)
                } else if case .movies = latestState {
                    navigationView.viewModel.stateDidChange(.movies)
                }
                // Dismiss browse's overlay.
                browseOverlayView.viewModel.isPresented = false
            // In-case the user wants to navigate back home's state.
            } else if homeViewModel.dataSourceState.value != .all
                        && !isPresented.value
                        && !browseOverlayView.viewModel.isPresented {
                hasHomeExpanded = false
                hasTvExpanded = false
                hasMoviesExpanded = false
                homeViewModel.dataSourceState.value = .all
                latestState = .home
                return
            // Default case.
            } else if homeViewModel.dataSourceState.value == .all
                        && !isPresented.value
                        && !browseOverlayView.viewModel.isPresented {
                return
            }
            
            hasHomeExpanded = true
        case .tvShows:
            // In-case the user wants to navigate to either tv-shows or movies state.
            if hasTvExpanded || browseOverlayView.viewModel.isPresented {
                // Set the navigation overlay state to main.
                self.state = .main
                // Present the overlay.
                isPresented.value = true
                return
            // In-case either tv-shows or movies hasn't been expanded and a presented brose overlay.
            }
            // Else, set the navigation settings by state value.
            hasHomeExpanded = false
            hasTvExpanded = true
            hasMoviesExpanded = false
            // Store the latest navigation state.
            latestState = .tvShows
            // Set home's table view data source state to tv shows.
            homeViewModel.dataSourceState.value = .tvShows
        case .movies:
            // In-case the user wants to navigate to either tv-shows or movies state.
            if hasMoviesExpanded || browseOverlayView.viewModel.isPresented {
                self.state = .main
                isPresented.value = true
                return
            }
            // Else, set the navigation settings by state value.
            hasHomeExpanded = false
            hasTvExpanded = false
            hasMoviesExpanded = true
            // Store the latest navigation state.
            latestState = .movies
            // Set home's table view data source state to tv shows.
            homeViewModel.dataSourceState.value = .movies
        case .categories:
            // Set the navigation overlay state to genres.
            self.state = .genres
            // Present the overlay.
            isPresented.value = true
        default: break
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let homeViewController = coordinator.viewController
        let homeViewModel = homeViewController!.viewModel!
        let navigationView = homeViewController!.navigationView!
        let category = NavigationOverlayView.Category(rawValue: indexPath.row)!
        let browseOverlayView = coordinator.viewController!.browseOverlayView!
        /// Execute operations based on the row that has been selected on the overlay.
        /// In-case the overlay state has been set to `.categories` value.
        if case .genres = state {
            // Allocate `browseOverlayView` data source.
            let section = category.toSection(with: homeViewModel)
            browseOverlayView.dataSource = BrowseOverlayCollectionViewDataSource(
                section: section,
                with: homeViewModel)
            // Present the overlay.
            browseOverlayView.viewModel.isPresented = true
        } else if state == .main {
            /// In-case the overlay state has been set to `.mainMenu` value.
            /// Extract a slice of the navigation view states.
            guard let options = NavigationView.State.allCases[3...5].toArray()[indexPath.row] as NavigationView.State? else { return }
            if case .tvShows = options {
                // In-case the user reselect `.tvShows` state value, return.
                if navigationView.viewModel.state.value == .tvShows { return }
                // Else, set the `navigationView` state to `.tvShows` value.
                navigationView.viewModel.state.value = .tvShows
                // Close the browse overlay.
                browseOverlayView.viewModel.isPresented = false
            } else if case .movies = options {
                if navigationView.viewModel.state.value == .movies { return }
                navigationView.viewModel.state.value = .movies
                
                browseOverlayView.viewModel.isPresented = false
            } else {
                // In-case the overlay state has been set to `.categories` value.
                state = .genres
                isPresentedDidChange()
                // Present the navigation overlay.
                isPresented.value = true
            }
        }
    }
}

/*
 //
 //  NavigationOverlayViewModel.swift
 //  netflix
 //
 //  Created by Zach Bazov on 20/09/2022.
 //

 import Foundation

 // MARK: - NavigationOverlayViewModel Type

 final class NavigationOverlayViewModel {
     
     // MARK: Properties
     
     private let coordinator: HomeViewCoordinator
     let isPresented: Observable<Bool> = Observable(false)
     let items: Observable<[Valuable]> = Observable([])
     private var state: NavigationOverlayTableViewDataSource.State = .main
     let numberOfSections: Int = 1
     private var latestState: NavigationView.State = .home
     private var hasHomeExpanded = false
     private var hasTvExpanded = false
     private var hasMoviesExpanded = false
     
     // MARK: Initializer
     
     /// Create a navigation overlay view view model object.
     /// - Parameter viewModel: Coordinating view model.
     init(with viewModel: HomeViewModel) {
         self.coordinator = viewModel.coordinator!
     }
 }

 // MARK: - Methods

 extension NavigationOverlayViewModel {
     /// Presentation of the view.
     func isPresentedDidChange() {
         if case true = isPresented.value { itemsDidChange() }
         
         animatePresentation()
     }
     /// Release data source changes and center the content.
     func dataSourceDidChange() {
         guard let navigationOverlayView = coordinator.viewController?.navigationView?.navigationOverlayView else {
             return
         }
         
         let tableView = navigationOverlayView.tableView
         /// In-case there is no allocated delegate.
         if tableView.delegate == nil {
             tableView.delegate = navigationOverlayView.dataSource
             tableView.dataSource = navigationOverlayView.dataSource
         }
         /// Release changes.
         tableView.reloadData()
         /// Center the content.
         tableView.centerVertically(on: navigationOverlayView)
     }
     /// Change `items` value based on the data source `state` value.
     private func itemsDidChange() {
         if case .main = state { items.value = NavigationView.State.allCases[3...5].toArray() }
         else if case .genres = state { items.value = NavigationOverlayView.Category.allCases }
         else { items.value = [] }
     }
     /// Animate the presentation of the view.
     private func animatePresentation() {
         guard let navigationOverlayView = coordinator.viewController?.navigationView?.navigationOverlayView else {
             return
         }
         
         navigationOverlayView.animateUsingSpring(
             withDuration: 0.5,
             withDamping: 1.0,
             initialSpringVelocity: 0.5,
             animations: { [weak self] in
                 guard let self = self else { return }
                 navigationOverlayView.alpha = self.isPresented.value ? 1.0 : 0.0
                 navigationOverlayView.tableView.alpha = self.isPresented.value ? 1.0 : 0.0
                 navigationOverlayView.footerView.alpha = self.isPresented.value ? 1.0 : 0.0
                 navigationOverlayView.tabBar.alpha = self.isPresented.value ? 0.0 : 1.0
             },
             completion: { [weak self] done in
                 guard let self = self else { return }
                 /// In-case the overlay has been closed and animation is done.
                 if !self.isPresented.value && done {
                     navigationOverlayView.tableView.delegate = nil
                     navigationOverlayView.tableView.dataSource = nil
                 }
             })
     }
     
     func navigationViewStateDidChange(_ state: NavigationView.State) {
         guard let homeViewController = coordinator.viewController,
               let homeViewModel = homeViewController.viewModel,
               let navigationView = homeViewController.navigationView,
               let browseOverlayView = coordinator.viewController!.browseOverlayView else {
             return
         }
         
         switch state {
         case .home:
             if !isPresented.value && browseOverlayView.viewModel.isPresented {
                 if latestState == .tvShows {
                     hasTvExpanded = true
                     navigationView.viewModel.stateDidChange(.tvShows)
                 } else if latestState == .movies {
                     hasMoviesExpanded = true
                     navigationView.viewModel.stateDidChange(.movies)
                 }
                 
                 hasHomeExpanded = false
                 
                 browseOverlayView.viewModel.isPresented = false
             } else if homeViewModel.dataSourceState.value != .all
                         && !isPresented.value
                         && !browseOverlayView.viewModel.isPresented {
                 hasTvExpanded = false
                 hasMoviesExpanded = false
                 
                 hasHomeExpanded = false
                 
                 homeViewModel.dataSourceState.value = .all
                 
                 latestState = .home
                 return
             }
             
             if homeViewModel.dataSourceState.value == .all
                 && !isPresented.value
                 && !browseOverlayView.viewModel.isPresented {
                 return
             }
             
             if hasHomeExpanded {
                 hasTvExpanded = false
                 hasMoviesExpanded = false
                 
                 homeViewModel.dataSourceState.value = .all
                 
                 latestState = .home
             }
             
             hasHomeExpanded = true
         case .tvShows, .movies:
             let condition = state == .tvShows ? hasTvExpanded : hasMoviesExpanded
             // In-case either tv-shows or movies has been expanded or a presented browse overlay.
             if condition || browseOverlayView.viewModel.isPresented {
                 // Set the navigation overlay state to main.
                 self.state = .main
                 // Present the overlay.
                 isPresented.value = true
                 return
             // In-case either tv-shows or movies hasn't been expanded and a presented brose overlay.
             } else if !condition && browseOverlayView.viewModel.isPresented {
                 return
             }
             // Else, set the navigation settings state-based.
             hasHomeExpanded = false
             hasTvExpanded = state == .tvShows ? true : false
             hasMoviesExpanded = state == .movies ? true : false
             // Store the latest navigation state.
             latestState = state == .tvShows ? .tvShows : .movies
             // Set home's table view data source state to tv shows.
             homeViewModel.dataSourceState.value = state == .tvShows ? .tvShows : .movies
         case .categories:
             // Set the navigation overlay state to genres.
             self.state = .genres
             // Present the overlay.
             isPresented.value = true
         default: break
         }
     }
     
     func didSelectRow(at indexPath: IndexPath) {
         let homeViewController = coordinator.viewController
         let homeViewModel = homeViewController!.viewModel!
         let navigationView = homeViewController!.navigationView!
         let category = NavigationOverlayView.Category(rawValue: indexPath.row)!
         let browseOverlayView = coordinator.viewController!.browseOverlayView!
         /// Execute operations based on the row that has been selected on the overlay.
         /// In-case the overlay state has been set to `.categories` value.
         if case .genres = state {
             // Allocate `browseOverlayView` data source.
             let section = category.toSection(with: homeViewModel)
             browseOverlayView.dataSource = BrowseOverlayCollectionViewDataSource(
                 section: section,
                 with: homeViewModel)
             // Present the overlay.
             browseOverlayView.viewModel.isPresented = true
         } else if state == .main {
             /// In-case the overlay state has been set to `.mainMenu` value.
             /// Extract a slice of the navigation view states.
             guard let options = NavigationView.State.allCases[3...5].toArray()[indexPath.row] as NavigationView.State? else { return }
             if case .tvShows = options {
                 // In-case the user reselect `.tvShows` state value, return.
                 if navigationView.viewModel.state.value == .tvShows { return }
                 // Else, set the `navigationView` state to `.tvShows` value.
                 navigationView.viewModel.state.value = .tvShows
                 // Close the browse overlay.
                 browseOverlayView.viewModel.isPresented = false
             } else if case .movies = options {
                 if navigationView.viewModel.state.value == .movies { return }
                 navigationView.viewModel.state.value = .movies
                 
                 browseOverlayView.viewModel.isPresented = false
             } else {
                 // In-case the overlay state has been set to `.categories` value.
                 state = .genres
                 isPresentedDidChange()
                 // Present the navigation overlay.
                 isPresented.value = true
             }
         }
     }
 }

 */

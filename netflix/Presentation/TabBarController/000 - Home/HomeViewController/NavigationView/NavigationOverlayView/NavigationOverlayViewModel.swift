//
//  NavigationOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import Foundation

final class NavigationOverlayViewModel {
    private let coordinator: HomeViewCoordinator
    let isPresented: Observable<Bool> = Observable(false)
    let items: Observable<[Valuable]> = Observable([])
    private var state: NavigationOverlayTableViewDataSource.State = .mainMenu
    let numberOfSections: Int = 1
    private var latestState: NavigationView.State = .home
    private var hasHomeExpanded = false
    private var hasTvExpanded = false
    private var hasMoviesExpanded = false
    /// Create a navigation overlay view view model object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

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
        if case .mainMenu = state { items.value = NavigationView.State.allCases[3...5].toArray() }
        else if case .categories = state { items.value = NavigationOverlayView.Category.allCases }
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
            } else if homeViewModel.dataSourceState.value != .all && !isPresented.value && !browseOverlayView.viewModel.isPresented {
                hasTvExpanded = false
                hasMoviesExpanded = false
                
                hasHomeExpanded = false
                
                homeViewModel.dataSourceState.value = .all
                
                latestState = .home
                return
            }
            
            if homeViewModel.dataSourceState.value == .all && !isPresented.value && !browseOverlayView.viewModel.isPresented {
                return
            }
            
            if hasHomeExpanded {
                hasTvExpanded = false
                hasMoviesExpanded = false
                
                homeViewModel.dataSourceState.value = .all
                
                latestState = .home
            }
            
            hasHomeExpanded = true
        case .tvShows:
            if hasTvExpanded {
                self.state = .mainMenu
                isPresented.value = true
                
                if !hasTvExpanded && browseOverlayView.viewModel.isPresented {
//                    browseOverlayView.dataSource?.updateItems()
                    return
                } else if hasTvExpanded && browseOverlayView.viewModel.isPresented {
                    self.state = .mainMenu
                    isPresented.value = true
                }
            }
            
            hasHomeExpanded = false
            hasTvExpanded = true
            hasMoviesExpanded = false
            
            homeViewModel.dataSourceState.value = .series
            
            latestState = .tvShows
        case .movies:
            if hasMoviesExpanded {
                self.state = .mainMenu
                isPresented.value = true
                
                if !hasMoviesExpanded && browseOverlayView.viewModel.isPresented {
                    return
                } else if hasMoviesExpanded && browseOverlayView.viewModel.isPresented {
                    self.state = .mainMenu
                    isPresented.value = true
                }
            }
            
            hasHomeExpanded = false
            hasTvExpanded = false
            hasMoviesExpanded = true
            
            homeViewModel.dataSourceState.value = .films
            
            latestState = .movies
        case .categories:
            if !isPresented.value && !browseOverlayView.viewModel.isPresented {
                self.state = .categories
                isPresented.value = true
            }
            
            if browseOverlayView.viewModel.isPresented {
                self.state = .categories
                isPresented.value = true
            } else {
                hasTvExpanded = false
                hasMoviesExpanded = false
            }
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
        if case .categories = state {
            /// Allocate `browseOverlayView` data source.
            let section = category.toSection(with: homeViewModel)
            browseOverlayView.dataSource = BrowseOverlayCollectionViewDataSource(
                section: section,
                with: homeViewModel)
            /// Present the overlay.
            browseOverlayView.viewModel.isPresented = true
        } else if state == .mainMenu {
            /// In-case the overlay state has been set to `.mainMenu` value.
            /// Extract a slice of the navigation view states.
            guard let options = NavigationView.State.allCases[3...5].toArray()[indexPath.row] as NavigationView.State? else { return }
            if case .tvShows = options {
                /// In-case the user reselect `.tvShows` state value, return.
                if navigationView.viewModel.state.value == .tvShows { return }
                /// Else, set the `navigationView` state to `.tvShows` value.
                navigationView.viewModel.state.value = .tvShows
                /// Close the browse overlay.
                browseOverlayView.viewModel.isPresented = false
            } else if case .movies = options {
                if navigationView.viewModel.state.value == .movies { return }
                navigationView.viewModel.state.value = .movies
                
                browseOverlayView.viewModel.isPresented = false
            } else {
                /// In-case the overlay state has been set to `.categories` value.
                state = .categories
                isPresentedDidChange()
                /// Present the navigation overlay.
                isPresented.value = true
            }
        }
    }
}

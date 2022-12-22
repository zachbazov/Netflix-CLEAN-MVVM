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
    /// The `NavigationView` designed to contain two phases for navigation methods.
    /// Phase #1: First cycle of the navigation, switching between the navigation states,
    ///           simply by clicking (selecting) one of them.
    /// Phase #2: The expansion cycle of the navigation,
    ///           which controls the presentations of `NavigationOverlayView` & `BrowseOverlayView`.
    ///           If needed, switch between the table view data-source's state
    ///           to display other data (e.g. series, films or all).
    /// - Parameter state: corresponding navigation's state value.
    func navigationViewStateDidChange(_ state: NavigationView.State) {
        guard let rootCoordinator = Application.current.rootCoordinator as RootCoordinator?,
              let tabCoordinator = Application.current.rootCoordinator.tabCoordinator,
              let homeViewController = coordinator.viewController,
              let navigationView = homeViewController.navigationView,
              let browseOverlay = homeViewController.browseOverlayView,
              var lastSelection = tabCoordinator.viewController?.viewModel.latestHomeNavigationState ?? .home as NavigationView.State? else {
            return
        }
        
        switch state {
        case .home:
            /// - PHASE #1:
            /// In-case `homeItemView` hasn't been selected.
            if !navigationView.homeItemView.viewModel.isSelected {
                /// Change view selection.
                navigationView.homeItemView.viewModel.isSelected = true
                navigationView.tvShowsItemView.viewModel.isSelected = false
                navigationView.moviesItemView.viewModel.isSelected = false
                /// - PHASE #2-A:
                /// Firstly, check for a case where the browser overlay is presented and home's table view
                /// data source state has been set to 'all' state.
                if browseOverlay.viewModel.isPresented && homeViewController.viewModel.dataSourceState.value == .all {
                    /// In-case `browseOverlayView` has been presented, hide it.
                    browseOverlay.viewModel.isPresented = false
                    /// Apply `NavigationView` state changes.
                    navigationView.viewModel.stateDidChange(lastSelection)
                    /// Based the navigation last selection, change selection settings.
                    if tabCoordinator.viewController?.viewModel.latestHomeNavigationState == .tvShows {
                        navigationView.homeItemView.viewModel.isSelected = false
                        navigationView.tvShowsItemView.viewModel.isSelected = true
                        navigationView.moviesItemView.viewModel.isSelected = false
                    } else if lastSelection == .movies {
                        navigationView.homeItemView.viewModel.isSelected = false
                        navigationView.tvShowsItemView.viewModel.isSelected = false
                        navigationView.moviesItemView.viewModel.isSelected = true
                    }
                } else {
                    /// - PHASE #2-B:
                    /// Secondly, check for a case where the browser overlay is presented.
                    /// and the navigation view state has been set to 'tvShows' or 'movies'.
                    if browseOverlay.viewModel.isPresented {
                        /// In-case the browser view has been presented, hide it.
                        browseOverlay.viewModel.isPresented = false
                        /// Apply navigation view state changes.
                        navigationView.viewModel.stateDidChange(lastSelection)
                    } else {
                        /// Store the latest navigation view state.
                        tabCoordinator.viewController?.viewModel.latestHomeNavigationState = .home
                        /// Re-coordinate with a new view-controller instance.
                        rootCoordinator.reallocateTabController()
                    }
                }
            } else {
                /// - PHASE #2-C:
                /// Thirdly, check for a case where the browser overlay is presented.
                /// Otherwise, in-case where the `lastSelection` value
                /// is set to either 'tvShows' or 'movies', reset it and initiate re-coordination procedure.
                if browseOverlay.viewModel.isPresented {
                    browseOverlay.viewModel.isPresented = false
                } else {
                    /// In-case the last selection is either set to both media types states (series and films).
                    /// Initiate re-coordination procedure, and reset `lastSelection` value to home state.
                    if lastSelection == .tvShows || lastSelection == .movies {
                        tabCoordinator.viewController?.viewModel.latestHomeNavigationState = .home
                        
                        rootCoordinator.reallocateTabController()
                        /// Reset to home state.
                        lastSelection = .home
                    } else {
                        /// Occurs once home state has been restored to the navigation view state,
                        /// and `browseOverlayView` view presentation is hidden.
                        /// Thus, this case represents the initial view's navigation state.
                    }
                }
            }
        case .tvShows:
            lastSelection = .tvShows
            
            if !navigationView.tvShowsItemView.viewModel.isSelected {
                navigationView.homeItemView.viewModel.isSelected = false
                navigationView.tvShowsItemView.viewModel.isSelected = true
                navigationView.moviesItemView.viewModel.isSelected = false
                
                tabCoordinator.viewController?.viewModel.latestHomeNavigationState = .tvShows
                
                rootCoordinator.reallocateTabController()
            } else {
                self.state = .mainMenu
                isPresented.value = true
            }
        case .movies:
            lastSelection = .movies
            
            if !navigationView.moviesItemView.viewModel.isSelected {
                navigationView.homeItemView.viewModel.isSelected = false
                navigationView.tvShowsItemView.viewModel.isSelected = false
                navigationView.moviesItemView.viewModel.isSelected = true
                
                tabCoordinator.viewController?.viewModel.latestHomeNavigationState = .movies
                
                rootCoordinator.reallocateTabController()
            } else {
                self.state = .mainMenu
                isPresented.value = true
            }
        case .categories:
            self.state = .categories
            isPresented.value = true
        default:
            break
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

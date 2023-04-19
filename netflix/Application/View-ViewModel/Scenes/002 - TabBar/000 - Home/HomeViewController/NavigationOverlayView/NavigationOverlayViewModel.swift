//
//  NavigationOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var isPresented: Observable<Bool> { get }
    var items: Observable<[Valuable]> { get }
    var state: NavigationOverlayTableViewDataSource.State { get }
    var numberOfSections: Int { get }
    var rowHeight: CGFloat { get }
    
    func isPresentedDidChange()
    func dataSourceDidChange()
    func itemsDidChange()
    func didSelectRow(at indexPath: IndexPath)
}

// MARK: - NavigationOverlayViewModel Type

final class NavigationOverlayViewModel {
    fileprivate let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    let items: Observable<[Valuable]> = Observable([])
    var state: NavigationOverlayTableViewDataSource.State = .main
    let numberOfSections: Int = 1
    let rowHeight: CGFloat = 56.0
    
    /// Create a navigation overlay view view model object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension NavigationOverlayViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension NavigationOverlayViewModel: ViewModelProtocol {
    func removeBlurness() {
        guard let navigationOverlay = coordinator.viewController?.navigationOverlayView else { return }
        
        navigationOverlay.opaqueView?.remove()
    }
    
    /// Presentation of the view.
    func isPresentedDidChange() {
        guard isPresented.value else { return }
        
        itemsDidChange()
    }
    
    /// Release data source changes and center the content.
    func dataSourceDidChange() {
        guard let navigationOverlayView = coordinator.viewController?.navigationOverlayView else { return }
        
        let tableView = navigationOverlayView.tableView
        // In-case there is no allocated delegate.
        tableView.delegate = navigationOverlayView.dataSource
        tableView.dataSource = navigationOverlayView.dataSource
        
        navigationOverlayView.opaqueView?.add()
        // Release changes.
        tableView.reloadData()
        // Center the content.
        tableView.contentInset = .init(top: 32.0, left: .zero, bottom: .zero, right: .zero)
    }
    
    /// Change `items` value based on the data source `state` value.
    fileprivate func itemsDidChange() {
        switch state {
        case .main:
            items.value = SegmentControlView.State.allCases[1...3].toArray()
        case .genres:
            items.value = NavigationOverlayView.Category.allCases
        default:
            items.value = []
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let homeViewController = coordinator.viewController
        let homeViewModel = homeViewController!.viewModel!
        let segmentControlView = homeViewController!.segmentControlView
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
//            homeViewController?.blurryContainer.layer.removeFromSuperlayer()
        } else if state == .main {
            /// In-case the overlay state has been set to `.mainMenu` value.
            /// Extract a slice of the navigation view states.
            guard let options = SegmentControlView.State.allCases[indexPath.row] as SegmentControlView.State? else { return }
            if case .tvShows = options {
                // In-case the user reselect `.tvShows` state value, return.
                if segmentControlView?.viewModel.state.value == .tvShows { return }
                // Else, set the `navigationView` state to `.tvShows` value.
                segmentControlView?.viewModel.state.value = .tvShows
                // Close the browse overlay.
                browseOverlayView.viewModel.isPresented = false
            } else if case .movies = options {
                if segmentControlView?.viewModel.state.value == .movies { return }
                segmentControlView?.viewModel.state.value = .movies
                
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

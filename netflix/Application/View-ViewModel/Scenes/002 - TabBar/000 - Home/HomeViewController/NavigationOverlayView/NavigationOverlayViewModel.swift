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
        
        tableView.delegate = navigationOverlayView.dataSource
        tableView.dataSource = navigationOverlayView.dataSource
        
        navigationOverlayView.opaqueView?.add()
        
        tableView.reloadData()
        
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
        guard let controller = coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let segmentControlView = controller.segmentControlView,
              let category = NavigationOverlayView.Category(rawValue: indexPath.row),
              let browseOverlayView = controller.browseOverlayView
        else { return }
        
        switch state {
        case .none:
            break
        case .main:
            guard let options = SegmentControlView.State.allCases[indexPath.row] as SegmentControlView.State? else { return }
            
            switch options {
            case .main:
                break
            case .tvShows:
                if segmentControlView.viewModel.state.value == .tvShows { return }
                
                segmentControlView.viewModel.state.value = .tvShows
                
                browseOverlayView.viewModel.isPresented.value = false
            case .movies:
                if segmentControlView.viewModel.state.value == .movies { return }
                
                segmentControlView.viewModel.state.value = .movies
                
                browseOverlayView.viewModel.isPresented.value = false
            case .categories:
                state = .genres
                
                isPresentedDidChange()
                
                isPresented.value = true
            }
        case .genres:
            controller.dataSource?.style.removeGradient()
            
            let section = category.toSection(with: homeViewModel)
            
            browseOverlayView.viewModel.section.value = section
            
            coordinator.coordinate(to: .browse)
        }
    }
}

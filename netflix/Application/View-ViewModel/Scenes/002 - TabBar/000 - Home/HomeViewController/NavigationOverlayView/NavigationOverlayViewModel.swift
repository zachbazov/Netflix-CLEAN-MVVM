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
    var items: [Valuable] { get }
    var state: Observable<NavigationOverlayTableViewDataSource.State> { get }
    var numberOfSections: Int { get }
    var rowHeight: CGFloat { get }
    
    func itemsDidChange()
    func didSelectRow(at indexPath: IndexPath)
}

// MARK: - NavigationOverlayViewModel Type

final class NavigationOverlayViewModel {
    let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    var items: [Valuable] = []
    let state: Observable<NavigationOverlayTableViewDataSource.State> = Observable(.main)
    let numberOfSections: Int = 1
    let rowHeight: CGFloat = 56.0
    
    var currentCategory: NavigationOverlayView.Category = .home
    
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
    /// Change `items` value based on the data source `state` value.
    func itemsDidChange() {
        switch state.value {
        case .main:
            items = SegmentControlView.State.allCases[0...3].toArray()
        case .genres:
            items = NavigationOverlayView.Category.allCases
        default:
            items = []
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let controller = coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let segmentControl = controller.segmentControlView,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        switch state.value {
        case .none:
            break
        case .main:
            guard let states = SegmentControlView.State.allCases[indexPath.row] as SegmentControlView.State? else { return }
            
            switch states {
            case .main:
                segmentControl.viewModel?.state.value = .main
            case .tvShows:
                guard segmentControl.viewModel.state.value != .tvShows else { print(1);return }
                
                let section = Section(id: 1111, title: "BrowseOverlay", media: controller.viewModel.media)
                
                controller.browseOverlayView?.dataSource?.items = section.media
                
                browseOverlay.viewModel.section.value = section
                
                segmentControl.viewModel.state.value = .tvShows
            case .movies:
                guard segmentControl.viewModel.state.value != .movies else { print(11);return }
                
                let section = Section(id: 2222, title: "BrowseOverlay", media: controller.viewModel.media)
                
                controller.browseOverlayView?.dataSource?.items = section.media
                
                browseOverlay.viewModel.section.value = section
                
                segmentControl.viewModel.state.value = .movies
            case .categories:
                state.value = .genres
                
                isPresented.value = true
            }
        case .genres:
            controller.dataSource?.style.removeGradient()
            
            guard let category = NavigationOverlayView.Category(rawValue: indexPath.row) else { return }
            
            currentCategory = category
            
            let section = category.toSection(with: homeViewModel)
            
            controller.browseOverlayView?.dataSource?.items = section.media
            
            browseOverlay.viewModel.section.value = section
            
            coordinator.coordinate(to: .browse)
        }
    }
}

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
    var state: Observable<NavigationOverlayTableViewDataSource.State> { get }
    var items: [Valuable] { get }
    var category: NavigationOverlayView.Category { get }
    var segment: SegmentControlView.State { get }
    var numberOfSections: Int { get }
    var rowHeight: CGFloat { get }
    
    func updateItems()
    func selectRow(at indexPath: IndexPath)
    func selectSegment(at indexPath: IndexPath)
    func selectCategory(at indexPath: IndexPath)
}

// MARK: - NavigationOverlayViewModel Type

final class NavigationOverlayViewModel {
    let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    let state: Observable<NavigationOverlayTableViewDataSource.State> = Observable(.none)
    
    fileprivate(set) var items: [Valuable] = []
    fileprivate(set) var category: NavigationOverlayView.Category = .display
    fileprivate var segment: SegmentControlView.State = .main
    
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
    /// Change `items` value based on the data source `state` value.
    func updateItems() {
        switch state.value {
        case .main:
            items = SegmentControlView.State.allCases[0...3].toArray()
        case .genres:
            items = NavigationOverlayView.Category.allCases
        default:
            items = []
        }
    }
    
    func selectRow(at indexPath: IndexPath) {
        switch state.value {
        case .none:
            break
        case .main:
            selectSegment(at: indexPath)
        case .genres:
            selectCategory(at: indexPath)
        }
    }
    
    fileprivate func selectSegment(at indexPath: IndexPath) {
        guard let segment = SegmentControlView.State(rawValue: indexPath.row) else { return }
        
        self.segment = segment
        
        guard let controller = coordinator.viewController, let segmentControl = controller.segmentControlView else { return }
        
        segmentControl.viewModel.segment.value = segment
        
        segmentControl.viewModel.isSegmentSelected = false
        
        segmentControl.viewModel.state.value = segment
    }
    
    fileprivate func selectCategory(at indexPath: IndexPath) {
        guard let controller = coordinator.viewController,
              let segmentControl = controller.segmentControlView,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        guard let category = NavigationOverlayView.Category(rawValue: indexPath.row) else { return }
        
        self.category = category
        
        browseOverlay.viewModel.section.value = category.toSection()
        
        browseOverlay.viewModel.isPresented.value = true
        
        controller.dataSource?.style.removeGradient()
        
        switch self.segment {
        case .main:
            segmentControl.viewModel.segment.value = .all
            segmentControl.viewModel.isSegmentSelected = false
            segmentControl.viewModel.state.value = .all
        case .all:
            segmentControl.viewModel.segment.value = .all
            segmentControl.viewModel.isSegmentSelected = false
            segmentControl.viewModel.state.value = .all
        case .tvShows:
            segmentControl.viewModel.segment.value = .tvShows
            segmentControl.viewModel.isSegmentSelected = false
            segmentControl.viewModel.state.value = .tvShows
        case .movies:
            segmentControl.viewModel.segment.value = .movies
            segmentControl.viewModel.isSegmentSelected = false
            segmentControl.viewModel.state.value = .movies
        default: break
        }
    }
}

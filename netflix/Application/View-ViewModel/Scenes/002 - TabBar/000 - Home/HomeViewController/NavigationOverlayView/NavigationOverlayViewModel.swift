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
    var numberOfSections: Int { get }
    var rowHeight: CGFloat { get }
    
    func itemsDidChange()
    func didSelectRow(at indexPath: IndexPath)
    func isPresentedWillChange(_ presented: Bool)
    func stateWillChange(_ state: NavigationOverlayTableViewDataSource.State)
    func stateDidChange(_ state: NavigationOverlayTableViewDataSource.State)
    func didSelectSegment(at indexPath: IndexPath)
    func didSelectCategory(at indexPath: IndexPath)
    func setCategory(_ category: NavigationOverlayView.Category)
}

// MARK: - NavigationOverlayViewModel Type

final class NavigationOverlayViewModel {
    let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    let state: Observable<NavigationOverlayTableViewDataSource.State> = Observable(.none)
    
    fileprivate(set) var items: [Valuable] = []
    fileprivate(set) var category: NavigationOverlayView.Category = .display
    
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
    fileprivate func itemsDidChange() {
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
        switch state.value {
        case .none:
            break
        case .main:
            didSelectSegment(at: indexPath)
        case .genres:
            didSelectCategory(at: indexPath)
        }
    }
    
    func isPresentedWillChange(_ presented: Bool) {
        isPresented.value = presented
    }
    
    func stateWillChange(_ state: NavigationOverlayTableViewDataSource.State) {
        self.state.value = state
    }
    
    func stateDidChange(_ state: NavigationOverlayTableViewDataSource.State) {
        itemsDidChange()
    }
    
    fileprivate func didSelectSegment(at indexPath: IndexPath) {
        guard let controller = coordinator.viewController,
              let segmentControl = controller.segmentControlView
        else { return }
        
        guard let segment = SegmentControlView.State(rawValue: indexPath.row) else { return }
        
        segmentControl.viewModel?.setSegment(segment)
        segmentControl.viewModel?.segmentDidChange(segment)
    }
    
    fileprivate func didSelectCategory(at indexPath: IndexPath) {
        guard let controller = coordinator.viewController,
              let segmentControl = controller.segmentControlView,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        guard let category = NavigationOverlayView.Category(rawValue: indexPath.row) else { return }
        
        setCategory(category)
        
        browseOverlay.viewModel.section.value = category.toSection()
        browseOverlay.viewModel.isPresented.value = true
        
        segmentControl.viewModel.segmentDidChange(segmentControl.viewModel.segment)
        
        controller.dataSource?.style.removeGradient()
    }
    
    fileprivate func setCategory(_ category: NavigationOverlayView.Category) {
        self.category = category
    }
}

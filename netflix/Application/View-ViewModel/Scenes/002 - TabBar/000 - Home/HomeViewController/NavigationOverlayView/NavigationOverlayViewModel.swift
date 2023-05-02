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
    
    func updateItems()
    func selectRow(at indexPath: IndexPath)
    func setCategory(for indexPath: IndexPath)
    func selectCategory(at indexPath: IndexPath)
}

// MARK: - NavigationOverlayViewModel Type

final class NavigationOverlayViewModel {
    let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    let state: Observable<NavigationOverlayTableViewDataSource.State> = Observable(.none)
    
    var items: [Valuable] = []
    var category: NavigationOverlayView.Category = .display
    
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
        guard let controller = coordinator.viewController,
              let segmentControl = controller.segmentControlView
        else { return }
        
        switch state.value {
        case .none:
            break
        case .main:
            segmentControl.stateWillChange(at: indexPath)
        case .genres:
            selectCategory(at: indexPath)
        }
    }
    
    fileprivate func selectCategory(at indexPath: IndexPath) {
        guard let controller = coordinator.viewController,
              let segmentControl = controller.segmentControlView
        else { return }
        
        setCategory(for: indexPath)
        
        print(controller.viewModel.dataSourceState.value)
        segmentControl.viewModel?.state.value = .all
//        switch controller.viewModel.dataSourceState.value {
//        case .none:
//            segmentControl.viewModel?.state.value = .main
//        case .all:
//            segmentControl.viewModel?.state.value = .all
//        case .tvShows:
//            segmentControl.viewModel?.state.value = .tvShows
//        case .movies:
//            segmentControl.viewModel?.state.value = .movies
//        }
    }
    
    fileprivate func setCategory(for indexPath: IndexPath) {
        guard let category = NavigationOverlayView.Category(rawValue: indexPath.row) else { return }
        
        self.category = category
    }
}

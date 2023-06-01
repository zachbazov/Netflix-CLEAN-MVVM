//
//  PanelViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 06/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media? { get }
    var sectionAt: (MediaTableViewDataSource.Index) -> Section { get }
    var myList: MyList { get }
}

// MARK: - PanelViewModel Type

final class PanelViewModel {
    let coordinator: HomeViewCoordinator
    
    var media: Media?
    let sectionAt: (MediaTableViewDataSource.Index) -> Section
    let myList: MyList = Application.app.services.myList
    
    init(with viewModel: ShowcaseTableViewCellViewModel) {
        self.coordinator = viewModel.coordinator
        
        guard let homeViewModel = self.coordinator.viewController?.viewModel else { fatalError() }
        
        let dataSourceState = homeViewModel.dataSourceState.value
        let showcases = homeViewModel.showcases
        let showcase = showcases[dataSourceState]
        
        self.media = showcase
        self.sectionAt = homeViewModel.section(at:)
    }
    
    deinit {
        media = nil
    }
}

// MARK: - ViewModel Implementation

extension PanelViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension PanelViewModel: ViewModelProtocol {}


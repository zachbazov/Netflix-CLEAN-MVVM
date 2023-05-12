//
//  ShowcaseTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 21/11/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media? { get }
    var myList: MyList { get }
    var sectionAt: (HomeTableViewDataSource.Index) -> Section { get }
}

// MARK: - ShowcaseTableViewCellViewModel Type

struct ShowcaseTableViewCellViewModel {
    let coordinator: HomeViewCoordinator
    
    let media: Media?
    let myList: MyList
    let sectionAt: (HomeTableViewDataSource.Index) -> Section
    
    /// Create a display table view cell view model.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else {
            fatalError("Unexpected coordinator \(HomeViewCoordinator.self) value.")
        }
        self.coordinator = coordinator
        self.media = viewModel.showcases[viewModel.dataSourceState.value]
        self.myList = viewModel.myList
        self.sectionAt = viewModel.section(at:)
    }
}

// MARK: - ViewModelProtocol Implementation

extension ShowcaseTableViewCellViewModel: ViewModelProtocol {}

// MARK: - ViewModel Implementation

extension ShowcaseTableViewCellViewModel: ViewModel {}

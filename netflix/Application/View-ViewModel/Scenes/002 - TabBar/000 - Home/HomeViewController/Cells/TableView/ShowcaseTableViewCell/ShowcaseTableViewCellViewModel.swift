//
//  ShowcaseTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 21/11/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var presentedMedia: Media? { get }
    var myList: MyList { get }
    var sectionAt: (HomeTableViewDataSource.Index) -> Section { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - ShowcaseTableViewCellViewModel Type

struct ShowcaseTableViewCellViewModel {
    var coordinator: HomeViewCoordinator?
    
    let presentedMedia: Media?
    let myList: MyList
    let sectionAt: (HomeTableViewDataSource.Index) -> Section
    
    /// Create a display table view cell view model.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.presentedMedia = viewModel.showcases[viewModel.dataSourceState.value ?? .all]
        self.myList = viewModel.myList
        self.sectionAt = viewModel.section(at:)
    }
}

// MARK: - ViewModelProtocol Implementation

extension ShowcaseTableViewCellViewModel: ViewModelProtocol {}

// MARK: - ViewModel Implementation

extension ShowcaseTableViewCellViewModel: ViewModel {}

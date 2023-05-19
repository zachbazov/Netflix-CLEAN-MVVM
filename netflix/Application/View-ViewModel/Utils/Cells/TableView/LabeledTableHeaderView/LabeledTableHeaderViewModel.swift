//
//  LabeledTableHeaderViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 15/11/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var index: Int { get }
    var title: String { get }
}

// MARK: - LabeledTableHeaderViewModel Type

struct LabeledTableHeaderViewModel {
    let coordinator: HomeViewCoordinator
    
    let index: Int
    
    var title: String {
        guard let viewModel = coordinator.viewController?.viewModel else { return .toBlank() }
        return viewModel.sections[index].title
    }
    
    init(index: Int, with viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        self.index = index
    }
}

// MARK: - ViewModel Implementation

extension LabeledTableHeaderViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension LabeledTableHeaderViewModel: ViewModelProtocol {}

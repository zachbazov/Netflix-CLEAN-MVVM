//
//  MediaHybridCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var section: Section { get }
}

// MARK: - MediaHybridCellViewModel Type

struct MediaHybridCellViewModel {
    let coordinator: HomeViewCoordinator
    
    var section: Section
    
    init(section: Section, with viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else {
            fatalError("Unexpected coordinator `\(type(of: viewModel.coordinator))` value.")
        }
        
        self.coordinator = coordinator
        self.section = section
    }
}

// MARK: - ViewModel Implementation

extension MediaHybridCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension MediaHybridCellViewModel: ViewModelProtocol {}

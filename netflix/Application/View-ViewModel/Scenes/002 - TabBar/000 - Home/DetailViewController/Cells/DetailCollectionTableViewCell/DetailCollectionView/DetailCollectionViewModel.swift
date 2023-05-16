//
//  DetailCollectionViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/05/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var state: DetailCollectionView.State { get }
}

// MARK: - DetailCollectionViewModel Type

final class DetailCollectionViewModel {
    let coordinator: DetailViewCoordinator
    
    var state: DetailCollectionView.State = .series
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
    }
}

// MARK: - ViewModel Implementation

extension DetailCollectionViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailCollectionViewModel: ViewModelProtocol {}

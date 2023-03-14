//
//  NavigationOverlayCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var title: String { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - NavigationOverlayCollectionViewCellViewModel Type

struct NavigationOverlayCollectionViewCellViewModel {
    let title: String
}

// MARK: - ViewModelProtocol Implementation

extension NavigationOverlayCollectionViewCellViewModel: ViewModelProtocol {}

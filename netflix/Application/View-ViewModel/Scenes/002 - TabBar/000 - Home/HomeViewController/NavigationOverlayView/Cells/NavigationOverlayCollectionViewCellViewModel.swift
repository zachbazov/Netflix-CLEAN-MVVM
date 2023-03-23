//
//  NavigationOverlayCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var title: String { get }
}

// MARK: - NavigationOverlayCollectionViewCellViewModel Type

struct NavigationOverlayCollectionViewCellViewModel {
    let title: String
}

// MARK: - ViewModelProtocol Implementation

extension NavigationOverlayCollectionViewCellViewModel: ViewModelProtocol {}

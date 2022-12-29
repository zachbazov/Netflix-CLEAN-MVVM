//
//  DetailNavigationViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - DetailNavigationViewItemViewModel Type

final class DetailNavigationViewItemViewModel {
    
    // MARK: Properties
    
    private let tag: Int
    private var isSelected: Bool
    
    var title: String {
        guard let tag = DetailNavigationView.State(rawValue: tag) else { fatalError() }
        switch tag {
        case .episodes: return Localization.TabBar.Detail.Navigation().leadingItem
        case .trailers: return Localization.TabBar.Detail.Navigation().centerItem
        case .similarContent: return Localization.TabBar.Detail.Navigation().trailingItem
        }
    }
    
    // MARK: Initializer
    
    /// Create a navigation view item view model object.
    /// - Parameter item: Corresponding item object.
    init(with item: DetailNavigationViewItem) {
        self.tag = item.tag
        self.isSelected = item.isSelected
    }
}

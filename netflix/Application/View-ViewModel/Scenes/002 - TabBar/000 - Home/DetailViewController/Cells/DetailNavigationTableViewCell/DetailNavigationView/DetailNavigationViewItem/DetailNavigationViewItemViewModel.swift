//
//  DetailNavigationViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var tag: Int { get }
    var isSelected: Bool { get }
    var title: String { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - DetailNavigationViewItemViewModel Type

final class DetailNavigationViewItemViewModel {
    fileprivate let tag: Int
    fileprivate var isSelected: Bool
    
    var title: String {
        guard let tag = DetailNavigationView.State(rawValue: tag) else { fatalError() }
        switch tag {
        case .episodes: return Localization.TabBar.Detail.Navigation().leadingItem
        case .trailers: return Localization.TabBar.Detail.Navigation().centerItem
        case .similarContent: return Localization.TabBar.Detail.Navigation().trailingItem
        }
    }
    /// Create a navigation view item view model object.
    /// - Parameter item: Corresponding item object.
    init(with item: DetailNavigationViewItem) {
        self.tag = item.tag
        self.isSelected = item.isSelected
    }
}

// MARK: - ViewModel Implementation

extension DetailNavigationViewItemViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailNavigationViewItemViewModel: ViewModelProtocol {}
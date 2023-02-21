//
//  DetailPanelViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var tag: Int { get }
    var isSelected: Observable<Bool> { get }
    var media: Media! { get }
    
    var systemImage: String { get }
    var title: String { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - DetailPanelViewItemViewModel Type

final class DetailPanelViewItemViewModel {
    let tag: Int
    let isSelected: Observable<Bool>
    var media: Media!
    
    var systemImage: String {
        guard let tag = DetailPanelViewItemConfiguration.Item(rawValue: tag) else { fatalError() }
        switch tag {
        case .myList: return isSelected.value ? "checkmark" : "plus"
        case .rate: return isSelected.value ? "hand.thumbsup.fill" : "hand.thumbsup"
        case .share: return "square.and.arrow.up"
        }
    }
    
    var title: String {
        guard let tag = DetailPanelViewItemConfiguration.Item(rawValue: tag) else { fatalError() }
        switch tag {
        case .myList: return Localization.TabBar.Detail.Panel().leadingItem
        case .rate: return Localization.TabBar.Detail.Panel().centerItem
        case .share: return Localization.TabBar.Detail.Panel().trailingItem
        }
    }
    /// Create a panel view item view model object.
    /// - Parameters:
    ///   - item: Corresponding view.
    ///   - viewModel: Coordinating view model.
    init(item: DetailPanelViewItem, with viewModel: DetailViewModel) {
        self.tag = item.tag
        self.isSelected = Observable(item.isSelected)
        self.media = viewModel.media
    }
    
    deinit { media = nil }
}

// MARK: - ViewModel Implementation

extension DetailPanelViewItemViewModel: ViewModel {}

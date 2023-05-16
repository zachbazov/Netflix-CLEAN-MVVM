//
//  DetailPanelViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var tag: Int { get }
    var isSelected: Observable<Bool> { get }
    var media: Media { get }
    
    var systemImage: String { get }
    var title: String { get }
    
    func isSelectedWillChange(_ selected: Bool)
}

// MARK: - DetailPanelViewItemViewModel Type

final class DetailPanelViewItemViewModel {
    let coordinator: DetailViewCoordinator
    
    let tag: Int
    let isSelected: Observable<Bool>
    let media: Media
    
    var systemImage: String {
        guard let tag = DetailPanelViewItem.Item(rawValue: tag) else { fatalError() }
        switch tag {
        case .myList: return isSelected.value ? "checkmark" : "plus"
        case .rate: return isSelected.value ? "hand.thumbsup.fill" : "hand.thumbsup"
        case .share: return "square.and.arrow.up"
        }
    }
    
    var title: String {
        guard let tag = DetailPanelViewItem.Item(rawValue: tag) else { fatalError() }
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
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        self.tag = item.tag
        self.isSelected = Observable(false)
        
        guard let media = viewModel.media else { fatalError() }
        self.media = media
    }
}

// MARK: - ViewModel Implementation

extension DetailPanelViewItemViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailPanelViewItemViewModel: ViewModelProtocol {
    func isSelectedWillChange(_ selected: Bool) {
        isSelected.value = selected
    }
}

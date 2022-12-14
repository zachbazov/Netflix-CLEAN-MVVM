//
//  DetailPanelViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - DetailPanelViewItemViewModel Type

final class DetailPanelViewItemViewModel {
    
    // MARK: Properties
    
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
    
    // MARK: Initializer
    
    /// Create a panel view item view model object.
    /// - Parameters:
    ///   - item: Corresponding view.
    ///   - viewModel: Coordinating view model.
    init(item: DetailPanelViewItem, with viewModel: DetailViewModel) {
        self.tag = item.tag
        self.isSelected = Observable(item.isSelected)
        self.media = viewModel.media
        self.setupObservers(on: item)
    }
    
    // MARK: Deinitializer
    
    deinit {
        removeObservers()
        media = nil
    }
}

// MARK: - Observers

extension DetailPanelViewItemViewModel {
    private func setupObservers(on item: DetailPanelViewItem) {
        isSelected.observe(on: self) { _ in item.configuration?.viewDidConfigure() }
    }
    
    func removeObservers() {
        isSelected.remove(observer: self)
    }
}

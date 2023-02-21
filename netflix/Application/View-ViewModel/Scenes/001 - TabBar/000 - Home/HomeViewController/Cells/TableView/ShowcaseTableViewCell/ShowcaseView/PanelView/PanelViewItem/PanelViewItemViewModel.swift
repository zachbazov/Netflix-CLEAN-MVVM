//
//  PanelViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import Foundation

// MARK: - PanelViewItemViewModel Type

final class PanelViewItemViewModel {
    let tag: Int
    let isSelected: Observable<Bool>
    var media: Media!
    
    var systemImage: String {
        let leading = isSelected.value ? "checkmark" : "plus"
        let trailing = "info.circle"
        return tag == 0 ? leading : trailing
    }
    
    var title: String {
        let leadingTitle = Localization.TabBar.Home.Panel().leadingTitle
        let trailingTitle = Localization.TabBar.Home.Panel().trailingTitle
        let leading = leadingTitle
        let trailing = trailingTitle
        return tag == 0 ? leading : trailing
    }
    /// Create a panel view item view model object.
    /// - Parameters:
    ///   - item: Corresponding view.
    ///   - media: The media object to be interacted.
    init(item: PanelViewItem, with media: Media) {
        self.tag = item.tag
        self.isSelected = .init(item.isSelected)
        self.media = media
        self.setupObservers(on: item)
    }
    
    deinit {
        media = nil
    }
}

// MARK: - Observers

extension PanelViewItemViewModel {
    private func setupObservers(on item: PanelViewItem) {
        isSelected.observe(on: self) { _ in item.configuration?.viewDidConfigure() }
    }
    
    func removeObservers() {
        isSelected.remove(observer: self)
    }
}

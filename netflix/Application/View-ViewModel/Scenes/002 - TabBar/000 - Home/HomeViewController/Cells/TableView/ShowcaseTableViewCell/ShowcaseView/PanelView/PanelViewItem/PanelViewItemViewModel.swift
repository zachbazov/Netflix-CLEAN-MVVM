//
//  PanelViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
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

// MARK: - PanelViewItemViewModel Type

struct PanelViewItemViewModel {
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
    init?(item: PanelViewItem, with media: Media?) {
        guard media.isNotNil else { return nil }
        
        self.tag = item.tag
        self.isSelected = .init(item.isSelected)
        self.media = media
    }
}

// MARK: - ViewModel Implementation

extension PanelViewItemViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension PanelViewItemViewModel: ViewModelProtocol {}

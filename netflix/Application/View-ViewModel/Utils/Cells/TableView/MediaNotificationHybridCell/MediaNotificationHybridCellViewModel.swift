//
//  MediaNotificationHybridCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var image: String { get }
    var title: String { get }
    var indexPath: IndexPath { get }
}

// MARK: - MediaNotificationHybridCellViewModel Type

struct MediaNotificationHybridCellViewModel {
    let image: String
    let title: String
    let indexPath: IndexPath
    
    init(with item: AccountMenuItem, for indexPath: IndexPath) {
        self.image = item.image
        self.title = item.title
        self.indexPath = indexPath
    }
}

// MARK: - ViewModel Implementation

extension MediaNotificationHybridCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension MediaNotificationHybridCellViewModel: ViewModelProtocol {}

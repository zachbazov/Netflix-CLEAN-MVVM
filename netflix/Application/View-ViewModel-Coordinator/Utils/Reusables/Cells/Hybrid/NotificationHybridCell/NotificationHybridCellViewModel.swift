//
//  NotificationHybridCellViewModel.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import Foundation

// MARK: - NotificationHybridCellViewModel Type

struct NotificationHybridCellViewModel {
    let image: String
    let title: String
    let indexPath: IndexPath
    
    var isFirstRow: Bool {
        return indexPath.row == .zero
    }
    
    init(with item: MyNetflixMenuItem, for indexPath: IndexPath) {
        self.image = item.image ?? .toBlank()
        self.title = item.title
        self.indexPath = indexPath
    }
}

// MARK: - ViewModel Implementation

extension NotificationHybridCellViewModel: ViewModel {}

//
//  AccountMenuNotificationHybridCellViewModel.swift
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

// MARK: - AccountMenuNotificationHybridCellViewModel Type

struct AccountMenuNotificationHybridCellViewModel {
    let image: String
    let title: String
    let indexPath: IndexPath
    
    var isFirstRow: Bool {
        return indexPath.row == .zero
    }
    
    init(with item: AccountMenuItem, for indexPath: IndexPath) {
        self.image = item.image
        self.title = item.title
        self.indexPath = indexPath
    }
}

// MARK: - ViewModel Implementation

extension AccountMenuNotificationHybridCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension AccountMenuNotificationHybridCellViewModel: ViewModelProtocol {}

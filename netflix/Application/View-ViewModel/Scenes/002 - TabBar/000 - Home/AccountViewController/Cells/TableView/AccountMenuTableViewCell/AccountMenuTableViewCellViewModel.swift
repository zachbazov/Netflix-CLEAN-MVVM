//
//  AccountMenuTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import Foundation

// MARK: - ModelProtocol Type

private protocol ModelProtocol {
    var image: String { get }
    var title: String { get }
    
    init(with item: AccountMenuItem)
}

// MARK: - AccountMenuTableViewCellViewModel Type

struct AccountMenuTableViewCellViewModel {
    let image: String
    let title: String
    
    init(with item: AccountMenuItem) {
        self.image = item.image
        self.title = item.title
    }
}

// MARK: - ModelProtocol Implementation

extension AccountMenuTableViewCellViewModel: ModelProtocol {}

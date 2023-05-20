//
//  AccountMenuTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
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

// MARK: - ViewModelProtocol Implementation

extension AccountMenuTableViewCellViewModel: ViewModelProtocol {}

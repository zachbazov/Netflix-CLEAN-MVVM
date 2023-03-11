//
//  AccountOptionTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import Foundation

struct AccountOptionTableViewCellViewModel {
    let image: String
    let title: String
    
    init(with option: AccountMenuItem) {
        self.image = option.image
        self.title = option.title
    }
}

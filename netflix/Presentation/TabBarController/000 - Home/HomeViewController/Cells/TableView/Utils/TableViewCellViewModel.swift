//
//  TableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/09/2022.
//

import Foundation

// MARK: - TableViewCellViewModel Type

struct TableViewCellViewModel {
    
    // MARK: Properties
    
    let id: Int
    let title: String
    let media: [Media]
    
    // MARK: Initializer
    
    init(section: Section) {
        self.id = section.id
        self.title = section.title
        self.media = section.media
    }
}

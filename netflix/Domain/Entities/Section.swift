//
//  Section.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Section Type

final class Section {
    
    // MARK: Properties
    
    let id: Int
    let title: String
    var media: [Media]
    
    // MARK: Initializer
    
    init(id: Int, title: String, media: [Media]) {
        self.id = id
        self.title = title
        self.media = media
    }
}

// MARK: - Sectionable Implementation

extension Section: Sectionable {}

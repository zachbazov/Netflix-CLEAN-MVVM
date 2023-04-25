//
//  Section.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Sectionable Type

protocol Sectionable {
    var id: Int { get }
    var title: String { get }
}

// MARK: - Section Type

final class Section {
    let id: Int
    let title: String
    var media: [Media]
    
    init() {
        self.id = .zero
        self.title = .toBlank()
        self.media = []
    }
    
    init(id: Int, title: String, media: [Media]) {
        self.id = id
        self.title = title
        self.media = media
    }
}

// MARK: - Sectionable Implementation

extension Section: Sectionable {}

// MARK: -

extension Section {
    static var vacantValue: Section {
        return Section(id: .zero, title: .toBlank(), media: [])
    }
}

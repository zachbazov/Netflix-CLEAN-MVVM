//
//  SectionRepresentable.swift
//  netflix
//
//  Created by Zach Bazov on 03/06/2023.
//

import Foundation

// MARK: - Sectionable Type

protocol SectionRepresentable {
    var id: Int { get }
    var title: String { get }
}

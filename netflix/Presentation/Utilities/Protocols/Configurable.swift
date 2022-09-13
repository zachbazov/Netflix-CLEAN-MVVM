//
//  Configurable.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import Foundation

// MARK: - Configurable

protocol Configurable {
    func configure(_ section: Section?, with viewModel: DefaultHomeViewModel?)
}

extension Configurable {
    func configure(_ section: Section?, with viewModel: DefaultHomeViewModel?) {}
}

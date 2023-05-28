//
//  DataLoadable.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - DataLoadable Type

protocol DataLoadable {
    func dataWillLoad()
    func dataDidLoad()
}

// MARK: - DataLoadable Implementation

extension DataLoadable {
    func dataWillLoad() {}
    func dataDidLoad() {}
}

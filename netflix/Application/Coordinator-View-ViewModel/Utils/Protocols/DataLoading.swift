//
//  DataLoading.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - DataLoading Type

protocol DataLoading {
    func dataWillLoad()
    func dataDidLoad()
}

// MARK: - DataLoading Implementation

extension DataLoading {
    func dataWillLoad() {}
    func dataDidLoad() {}
}

//
//  HTTPRepresentable.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - HTTPRepresentable Type

protocol HTTPRepresentable {
    associatedtype Request
    associatedtype Response
}

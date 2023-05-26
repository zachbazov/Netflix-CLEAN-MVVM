//
//  Taskable.swift
//  netflix
//
//  Created by Zach Bazov on 26/05/2023.
//

import Foundation

// MARK: - Taskable Type

protocol Taskable {
    var task: Cancellable? { get }
}

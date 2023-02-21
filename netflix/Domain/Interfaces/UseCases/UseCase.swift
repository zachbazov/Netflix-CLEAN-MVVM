//
//  UseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - UseCase Type

protocol UseCase {
    associatedtype T: Repository
    var repository: T { get }
}

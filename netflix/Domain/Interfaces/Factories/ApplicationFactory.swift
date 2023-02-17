//
//  ApplicationFactory.swift
//  netflix
//
//  Created by Zach Bazov on 17/02/2023.
//

import Foundation

// MARK: - ApplicationFactory Type

protocol ApplicationFactory {
    func createApplicationDependencies() -> Application.Dependencies
}

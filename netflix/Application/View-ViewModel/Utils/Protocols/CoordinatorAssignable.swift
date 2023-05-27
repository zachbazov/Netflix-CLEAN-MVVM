//
//  CoordinatorAssignable.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - CoordinatorAssignable Type

protocol CoordinatorAssignable {
    associatedtype T: Coordinator
    
    var coordinator: T? { get set }
}

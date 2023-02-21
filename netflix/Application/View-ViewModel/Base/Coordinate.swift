//
//  Coordinate.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - Coordinable Type

protocol Coordinable {
    associatedtype Coordinator: Coordinate
    
    var coordinator: Coordinator? { get set }
}

// MARK: - Coordinate Type

protocol Coordinate {
    associatedtype Screen
    associatedtype View: UIViewController
    
    var viewController: View? { get set }
    
    func coordinate(to screen: Screen)
}

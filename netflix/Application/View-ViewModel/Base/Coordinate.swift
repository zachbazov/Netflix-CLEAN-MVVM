//
//  Coordinate.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit.UIViewController

// MARK: - Coordinate Protocol

protocol Coordinate {
    associatedtype Screen
    associatedtype View: UIViewController
    
    var viewController: View? { get set }
    
    func coordinate(to screen: Screen)
}

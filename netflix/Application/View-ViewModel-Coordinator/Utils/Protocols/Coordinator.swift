//
//  Coordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - Coordinator Type

protocol Coordinator {
    associatedtype Screen
    associatedtype ViewController: UIViewController
    
    var viewController: ViewController? { get set }
    
    func coordinate(to screen: Screen)
}

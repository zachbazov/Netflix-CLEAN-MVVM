//
//  ControllerViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/02/2023.
//

import Foundation

protocol ControllerViewModel {
    associatedtype Input
    associatedtype Output
    associatedtype Coordinator: Coordinate
    
    var coordinator: Coordinator? { get set }
    
    func transform(input: Input) -> Output
}

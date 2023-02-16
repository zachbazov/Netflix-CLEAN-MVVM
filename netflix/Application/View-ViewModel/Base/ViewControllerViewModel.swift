//
//  ViewControllerViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/02/2023.
//

import Foundation

protocol ViewControllerModeling {
    associatedtype ViewModelType: ViewControllerViewModel
    var viewModel: ViewModelType! { get set }
}

protocol ViewControllerViewModel {
    associatedtype Input
    associatedtype Output
    associatedtype CoordinatorType: Coordinate
    
    var coordinator: CoordinatorType? { get set }
    
    func transform(input: Input) -> Output
}

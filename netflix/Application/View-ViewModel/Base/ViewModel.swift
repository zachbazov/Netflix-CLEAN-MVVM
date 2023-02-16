//
//  ViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import Foundation

//protocol ViewModel {
//    associatedtype ViewModelType: ViewModel
//    var viewModel: ViewModelType! { get set }
//}

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

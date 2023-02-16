//
//  ViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

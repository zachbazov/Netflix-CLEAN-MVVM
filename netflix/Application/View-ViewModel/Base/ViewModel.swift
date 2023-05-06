//
//  ViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ViewModel Type

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    
    func viewDidLoad()
    func dataWillLoad()
    func dataDidLoad()
}

extension ViewModel {
    func transform(input: Void) {}
    
    func viewDidLoad() {}
    func dataWillLoad() {}
    func dataDidLoad() {}
}

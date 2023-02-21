//
//  ViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import Foundation

// MARK: - ViewModel Type

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    func viewDidLoad()
    func dataDidDownload()
}

extension ViewModel {
    func transform(input: Void) {}
    func viewDidLoad() {}
    func dataDidDownload() {}
}

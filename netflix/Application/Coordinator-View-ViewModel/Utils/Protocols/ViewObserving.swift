//
//  ViewObserving.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - ViewObserving Type

protocol ViewObserving {
    func viewWillBindObservers()
    func viewDidBindObservers()
    func viewWillUnbindObservers()
    func viewDidUnbindObservers()
}

// MARK: - ViewObserving Implementation

extension ViewObserving {
    func viewWillBindObservers() {}
    func viewDidBindObservers() {}
    func viewWillUnbindObservers() {}
    func viewDidUnbindObservers() {}
}

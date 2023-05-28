//
//  ViewObservable.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - ViewObservable Type

protocol ViewObservable {
    func viewWillBindObservers()
    func viewDidBindObservers()
    func viewWillUnbindObservers()
    func viewDidUnbindObservers()
}

// MARK: - ViewObservable Implementation

extension ViewObservable {
    func viewWillBindObservers() {}
    func viewDidBindObservers() {}
    func viewWillUnbindObservers() {}
    func viewDidUnbindObservers() {}
}

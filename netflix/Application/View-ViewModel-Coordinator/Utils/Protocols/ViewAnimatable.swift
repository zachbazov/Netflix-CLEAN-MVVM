//
//  ViewAnimatable.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - ViewAnimatable Type

protocol ViewAnimatable {
    func viewWillAnimateAppearance()
    func viewDidAnimateAppearance()
    func viewWillAnimateDisappearance()
    func viewDidAnimateDisappearance()
    func viewShouldAppear(_ presented: Bool)
}

// MARK: - ViewAnimatable Implementation

extension ViewAnimatable {
    func viewWillAnimateAppearance() {}
    func viewDidAnimateAppearance() {}
    func viewWillAnimateDisappearance() {}
    func viewDidAnimateDisappearance() {}
    func viewShouldAppear(_ presented: Bool) {
        guard presented else {
            return viewWillAnimateDisappearance()
        }
        
        viewWillAnimateAppearance()
    }
}

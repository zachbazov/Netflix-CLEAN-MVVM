//
//  ViewAnimating.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - ViewAnimating Type

protocol ViewAnimating {
    func viewWillAnimateAppearance()
    func viewDidAnimateAppearance()
    func viewWillAnimateDisappearance()
    func viewDidAnimateDisappearance()
    func viewShouldAppear(_ presented: Bool)
}

// MARK: - ViewAnimating Implementation

extension ViewAnimating {
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

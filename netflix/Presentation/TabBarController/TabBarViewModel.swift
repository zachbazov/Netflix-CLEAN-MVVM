//
//  TabBarViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - TabBarViewModel Type

final class TabBarViewModel {
    var coordinator: TabBarCoordinator?
}

// MARK: - ViewModel Implementation

extension TabBarViewModel: ViewModel {
    func transform(input: Void) {}
}

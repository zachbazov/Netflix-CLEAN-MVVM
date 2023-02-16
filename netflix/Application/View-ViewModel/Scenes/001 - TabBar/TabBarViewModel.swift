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

// MARK: - ViewControllerViewModel Implementation

extension TabBarViewModel: ViewControllerViewModel {
    func transform(input: Void) {}
}

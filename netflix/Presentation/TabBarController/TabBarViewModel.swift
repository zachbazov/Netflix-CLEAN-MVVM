//
//  TabBarViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

final class TabBarViewModel {
    var coordinator: TabBarCoordinator?
//    /// Home's table view data source latest state.
//    var latestHomeDataSourceState: HomeTableViewDataSource.State = .all
//    /// Home's navigation view latest state.
//    var latestHomeNavigationState: NavigationView.State = .home
//    /// Home display cell's display media cache.
//    var latestDisplayCache: [HomeTableViewDataSource.State: Media] = [:]
    /// NOTE:
    /// The use case for the `latest` properties is basicly to store the latest interacted states of the views,
    /// As reallocation done operating, restate the views by them.
}

extension TabBarViewModel: ViewModel {
    func transform(input: Void) {}
}

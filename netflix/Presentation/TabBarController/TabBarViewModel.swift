//
//  TabBarViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

final class TabBarViewModel: ViewModel {
    var coordinator: TabBarCoordinator?
    
    private(set) var homeDataSourceState: Observable<HomeTableViewDataSource.State> = Observable(.all)
    var homeNavigationState: NavigationView.State = .home
    
    func transform(input: Void) {}
}

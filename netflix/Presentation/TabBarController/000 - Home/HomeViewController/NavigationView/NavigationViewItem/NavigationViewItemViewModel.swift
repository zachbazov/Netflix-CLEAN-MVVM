//
//  NavigationViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 17/09/2022.
//

import Foundation

struct NavigationViewItemViewModel {
    let coordinator: HomeViewCoordinator
    let tag: Int
    var title: String!
    var image: String!
    var isSelected: Bool
    
    init(tag: Int, with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.isSelected = false
        self.tag = tag
        self.title = title(for: tag)
        self.image = image(for: tag)
    }
    
    private func title(for tag: Int) -> String? {
        guard let state = NavigationView.State(rawValue: tag) else { return nil }
        if case .tvShows = state { return "TV Shows" }
        else if case .movies = state { return "Movies" }
        else if case .categories = state { return "Categories" }
        else { return nil }
    }
    
    private func image(for tag: Int) -> String? {
        guard let state = NavigationView.State(rawValue: tag) else { return nil }
        if case .home = state { return "netflix-logo-sm" }
        else if case .airPlay = state { return "airplayvideo" }
        else if case .account = state { return "person.circle" }
        else { return nil }
    }
}

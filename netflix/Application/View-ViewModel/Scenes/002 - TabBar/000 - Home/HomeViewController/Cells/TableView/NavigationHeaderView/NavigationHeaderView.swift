//
//  NavigationHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 23/03/2023.
//

import UIKit

// MARK: - NavigationHeaderView Type

class NavigationHeaderView: TableViewHeaderView<TableViewHeaderFooterViewViewModel> {
    
    private(set) var navigationView: NavigationView!
    
    static func create(in tableView: UITableView,
                       at index: Int,
                       with homeViewModel: HomeViewModel) -> NavigationHeaderView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NavigationHeaderView.reuseIdentifier) as? NavigationHeaderView else { return nil }
        view.navigationView = NavigationView(on: view, with: homeViewModel)
        view.navigationView.constraintToSuperview(view)
        view.viewModel = .init()
        view.viewDidConfigure(at: index, with: homeViewModel)
        return view
    }
    
    override func viewDidConfigure(at index: Int, with homeViewModel: HomeViewModel) {
        
    }
}


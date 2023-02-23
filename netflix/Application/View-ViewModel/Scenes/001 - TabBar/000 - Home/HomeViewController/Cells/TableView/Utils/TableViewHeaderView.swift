//
//  TableViewHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 21/02/2023.
//

import UIKit

// MARK: - TableViewHeaderView Type

class TableViewHeaderView<T>: UITableViewHeaderFooterView where T: ViewModel {
    var viewModel: T!
    
    func viewDidConfigure(at index: Int, with homeViewModel: HomeViewModel) {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension TableViewHeaderView: ViewLifecycleBehavior {}

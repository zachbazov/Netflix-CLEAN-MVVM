//
//  NavigationOverlayTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - NavigationOverlayTableViewDataSource Type

final class NavigationOverlayTableViewDataSource: NSObject {
    
    // MARK: Properties
    
    private let viewModel: NavigationOverlayViewModel
    
    // MARK: Initializer
    
    /// Create a navigation overlay table view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: NavigationOverlayViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension NavigationOverlayTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return NavigationOverlayTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.isPresented.value = false
        viewModel.didSelectRow(at: indexPath)
        
        if case .none? = State(rawValue: indexPath.section) {}
    }
}

// MARK: - State Type

extension NavigationOverlayTableViewDataSource {
    /// Data source state representation.
    enum State: Int {
        case none
        case mainMenu
        case categories
    }
}

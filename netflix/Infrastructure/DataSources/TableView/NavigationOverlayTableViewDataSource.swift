//
//  NavigationOverlayTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: NavigationOverlayViewModel { get }
}

// MARK: - NavigationOverlayTableViewDataSource Type

final class NavigationOverlayTableViewDataSource: NSObject {
    fileprivate let viewModel: NavigationOverlayViewModel
    
    /// Create a navigation overlay table view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: NavigationOverlayViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - DataSourceProtocol Implementation

extension NavigationOverlayTableViewDataSource: DataSourceProtocol {}

// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension NavigationOverlayTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return NavigationOverlayTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.isPresented.value = false
        
        viewModel.selectRow(at: indexPath)
        
        if case .none? = State(rawValue: indexPath.section) {}
    }
}

// MARK: - State Type

extension NavigationOverlayTableViewDataSource {
    /// Data source state representation.
    enum State: Int {
        case none
        case main
        case genres
    }
}

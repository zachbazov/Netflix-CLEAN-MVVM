//
//  NavigationOverlayTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - NavigationOverlayTableViewDataSource Type

final class NavigationOverlayTableViewDataSource: TableViewDataSource {
    
    fileprivate let viewModel: NavigationOverlayViewModel
    
    init(with viewModel: NavigationOverlayViewModel) {
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return viewModel.numberOfSections
    }
    
    override func numberOfRows(in section: Int) -> Int {
        return viewModel.items.count
    }
    
    override func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell {
        return NavigationOverlayTableViewCell.create(on: tableView, for: indexPath, with: viewModel) as! T
    }
    
    override func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        tableView.estimatedSectionHeaderHeight = .zero
        tableView.estimatedSectionFooterHeight = .zero
        return viewModel.rowHeight
    }
    
    override func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {
        viewModel.isPresented.value = false
        
        viewModel.didSelectRow(at: indexPath)
        
        if case .none? = State(rawValue: indexPath.section) {}
    }
    
    override func willDisplayCellForRow(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
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

// MARK: - Private Implementation

extension NavigationOverlayTableViewDataSource {
    private func createDummyView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

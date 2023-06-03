//
//  AccountMenuTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var reusableViewPointSize: CGFloat { get }
}

// MARK: - AccountMenuTableViewDataSource Type

final class AccountMenuTableViewDataSource: TableViewDataSource {
    private let viewModel: AccountViewModel
    
    fileprivate let reusableViewPointSize: CGFloat = 1.0
    
    init(with viewModel: AccountViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.dataSourceDidChange()
    }
    
    override func numberOfSections() -> Int {
        return viewModel.menuItems.count
    }
    
    override func numberOfRows(in section: Int) -> Int {
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: section) else { return 1 }
        switch section {
        case .notifications:
            let menuItem = viewModel.menuItems[section.rawValue]
            return menuItem.isExpanded ?? false ? 2 : 1
        default:
            return 1
        }
    }
    
    override func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T : UITableViewCell {
        return AccountMenuNotificationHybridCell.create(expecting: AccountMenuNotificationHybridCell.self,
                                                        embedding: AccountMenuNotificationCollectionViewCell.self,
                                                        on: tableView,
                                                        for: indexPath,
                                                        with: viewModel) as! T
    }
    
    override func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: indexPath.section) else { return .zero }
        
        let pointSize: CGFloat = 56.0
        
        guard section == .notifications else { return pointSize }
        
        guard indexPath.row == .zero else {
            let count = CGFloat(viewModel.menuItems[indexPath.section].options?.count ?? 0)
            let cellHeight: CGFloat = 80.0
            let lineSpacing: CGFloat = 8.0
            return (count * cellHeight) + (count * lineSpacing)
        }
        
        return pointSize
    }
    
    override func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .notifications:
            guard indexPath.row == .zero else { return }
            
            viewModel.menuItems[section.rawValue].isExpanded = !(viewModel.menuItems[section.rawValue].isExpanded ?? false)
            
            tableView.reloadSections([section.rawValue], with: .automatic)
            tableView.isScrollEnabled = viewModel.menuItems[section.rawValue].isExpanded ?? false ? true : false
        case .myList:
            break
        case .appSettings:
            break
        case .account:
            break
        case .help:
            break
        }
    }
    
    override func willDisplayCellForRow(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    override func viewForHeader(in tableView: UITableView, at section: Int) -> UIView? {
        return createDummyView()
    }
    
    override func heightForHeader(in section: Int) -> CGFloat {
        return reusableViewPointSize
    }
    
    override func viewForFooter(in section: Int) -> UIView? {
        return createDummyView()
    }
    
    override func heightForFooter(in section: Int) -> CGFloat {
        return reusableViewPointSize
    }
}

// MARK: - DataSourceProtocol Implementation

extension AccountMenuTableViewDataSource: DataSourceProtocol {
    func dataSourceDidChange() {
        guard let tableView = viewModel.coordinator?.viewController?.tableView else { return }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

// MARK: - Index Type

extension AccountMenuTableViewDataSource {
    enum Section: Int {
        case notifications
        case myList
        case appSettings
        case account
        case help
    }
}

// MARK: - Private Implementation

extension AccountMenuTableViewDataSource {
    private func createDummyView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
}

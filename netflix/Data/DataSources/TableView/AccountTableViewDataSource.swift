//
//  AccountTableViewDataSource.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import UIKit

// MARK: - AccountTableViewDataSource Type

final class AccountTableViewDataSource: TableViewDataSource {
    private let viewModel: MyNetflixViewModel
    
    init(with viewModel: MyNetflixViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.dataSourceDidChange()
    }
    
    override func numberOfSections() -> Int {
        return viewModel.menuItems.count
    }
    
    override func numberOfRows(in section: Int) -> Int {
        guard let customSection = AccountTableViewDataSource.Section(rawValue: section) else { return 1 }
        
        switch customSection {
        case .notifications:
            let menuItem = viewModel.menuItems[customSection.rawValue]
            return menuItem.isExpanded ?? false ? 1 : 1
        case .downloads:
            return .zero
        default:
            return 1
        }
    }
    
    override func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let section = AccountTableViewDataSource.Section(rawValue: indexPath.section) else { fatalError() }
        
        switch section {
        case .profile:
            return MyNetflixProfileTableViewCell.create(of: MyNetflixProfileTableViewCell.self,
                                                        on: tableView,
                                                        for: indexPath,
                                                        with: viewModel) as! T
        case .notifications:
            return NotificationHybridCell.create(expecting: NotificationHybridCell.self,
                                                 embedding: NotificationCollectionViewCell.self,
                                                 on: tableView,
                                                 for: indexPath,
                                                 with: viewModel) as! T
        case .downloads:
            return .init()
        case .myList:
            return MyListHybridCell.create(expecting: MyListHybridCell.self,
                                           embedding: StandardCollectionViewCell.self,
                                           on: tableView,
                                           for: indexPath,
                                           with: viewModel) as! T
        case .trailersWatched:
            return TrailerHybridCell.create(expecting: TrailerHybridCell.self,
                                            embedding: StandardCollectionViewCell.self,
                                            on: tableView,
                                            for: indexPath,
                                            with: viewModel) as! T
        }
    }
    
    override func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        guard let section = AccountTableViewDataSource.Section(rawValue: indexPath.section) else { return .zero }
        
        let pointSize: CGFloat = 56.0
        
        switch section {
        case .profile:
            return 128.0
        case .notifications:
            let count = 1.0
            let cellHeight: CGFloat = 80.0
            let lineSpacing: CGFloat = 8.0
            let value = (count * cellHeight) + (count * lineSpacing)
            return value
        case .downloads:
            return pointSize
        case .myList:
            return 148.0
        case .trailersWatched:
            guard let itemCount = viewModel.menuItems[indexPath.section].items?.count else { return .zero }
            return itemCount == .zero ? .zero : 148.0
        }
    }
    
    override func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func willDisplayCellForRow(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    override func viewForHeader(in tableView: UITableView, at section: Int) -> UIView? {
        guard let section = AccountTableViewDataSource.Section(rawValue: section) else { return nil }
        
        switch section {
        case .profile:
            return MyNetflixNavigationTableHeaderView.create(of: MyNetflixNavigationTableHeaderView.self,
                                                             on: tableView,
                                                             for: section.rawValue,
                                                             with: viewModel)
        case .trailersWatched:
            guard let itemCount = viewModel.menuItems[section.rawValue].items?.count else { return nil }
            
            return itemCount == .zero ? UITableView.dummyView : ReferrableTableHeaderView.create(of: ReferrableTableHeaderView.self,
                                                                                                 on: tableView,
                                                                                                 for: section.rawValue,
                                                                                                 with: viewModel)
        default:
            return ReferrableTableHeaderView.create(of: ReferrableTableHeaderView.self,
                                                    on: tableView,
                                                    for: section.rawValue,
                                                    with: viewModel)
        }
    }
    
    override func heightForHeader(in section: Int) -> CGFloat {
        guard let section = AccountTableViewDataSource.Section(rawValue: section) else { return UITableView.reusableViewPointSize }
        
        switch section {
        case .myList:
            return 40.0
        case .trailersWatched:
            guard let itemCount = viewModel.menuItems[section.rawValue].items?.count else { return .zero }
            
            return itemCount == .zero ? .zero : 40.0
        default:
            return 56.0
        }
    }
    
    override func viewForFooter(in section: Int) -> UIView? {
        return UITableView.dummyView
    }
    
    override func heightForFooter(in section: Int) -> CGFloat {
        guard let section = AccountTableViewDataSource.Section(rawValue: section) else { return UITableView.reusableViewPointSize }
        
        switch section {
        case .notifications:
            return UITableView.spacerPointSize
        case .downloads:
            return UITableView.spacerPointSize
        default:
            return UITableView.reusableViewPointSize
        }
    }
}

// MARK: - Internal Implementation

extension AccountTableViewDataSource {
    func dataSourceDidChange() {
        guard let tableView = viewModel.coordinator?.viewController?.tableView else { return }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

// MARK: - Section Type

extension AccountTableViewDataSource {
    enum Section: Int {
        case profile
        case notifications
        case downloads
        case myList
        case trailersWatched
    }
}

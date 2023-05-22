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
    
    func createDummyView() -> UIView
    func dataSourceDidChange()
}

// MARK: - AccountMenuTableViewDataSource Type

final class AccountMenuTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: AccountViewModel
    
    fileprivate let reusableViewPointSize: CGFloat = 1.0
    
    deinit {
        print("deinit \(String(describing: Self.self))")
    }
    
    init(with viewModel: AccountViewModel) {
        self.viewModel = viewModel
        super.init()
        self.dataSourceDidChange()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: section) else { return 1 }
        switch section {
        case .notifications:
            let menuItem = viewModel.menuItems[section.rawValue]
            return menuItem.isExpanded ?? false ? 2 : 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return AccountMenuNotificationHybridCell.create(
            expecting: AccountMenuNotificationHybridCell.self,
            embedding: AccountMenuNotificationCollectionViewCell.self,
            on: tableView,
            for: indexPath,
            with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return reusableViewPointSize
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createDummyView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return reusableViewPointSize
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return createDummyView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
}

// MARK: - DataSourceProtocol Implementation

extension AccountMenuTableViewDataSource: DataSourceProtocol {
    fileprivate func createDummyView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
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

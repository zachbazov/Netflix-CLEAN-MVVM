//
//  AccountMenuTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import UIKit

// MARK: - AccountMenuTableViewDataSource Type

final class AccountMenuTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: AccountViewModel
    
    private var notificationCell: AccountMenuTableViewCell?
    private var myListCell: AccountMenuTableViewCell?
    private var appSettingsCell: AccountMenuTableViewCell?
    private var accountCell: AccountMenuTableViewCell?
    private var helpCell: AccountMenuTableViewCell?
    
    init(with viewModel: AccountViewModel) {
        self.viewModel = viewModel
        super.init()
        self.dataSourceDidChange()
    }
    
    func dataSourceDidChange() {
        guard let tableView = viewModel.coordinator?.viewController?.tableView else { return }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: section) else { return 1 }
        switch section {
        case .notifications:
            let menuItem = viewModel.menuItems[section.rawValue]
            if menuItem.isExpanded ?? false {
                return menuItem.options!.count + 1
            } else {
                return 1
            }
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: indexPath.section) else { return .init() }
        switch section {
        case .notifications:
            notificationCell = AccountMenuTableViewCell.create(in: tableView, at: indexPath, with: viewModel)
            if indexPath.row == 0 {
                notificationCell?.label?.text = viewModel.menuItems[indexPath.section].title
                if viewModel.menuItems[section.rawValue].isExpanded ?? false {
                    let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.hexColor("b3b3b3"))
                    notificationCell?.accessoryView = UIImageView(image: image)
                } else {
                    let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.hexColor("b3b3b3"))
                    notificationCell?.accessoryView = UIImageView(image: image)
                }
            } else {
                notificationCell?.label?.text = viewModel.menuItems[indexPath.section].options?[indexPath.row - 1]
                notificationCell?.accessoryView = nil
            }
            return notificationCell!
        case .myList:
            myListCell = AccountMenuTableViewCell.create(in: tableView, at: indexPath, with: viewModel)
            return myListCell!
        case .appSettings:
            appSettingsCell = AccountMenuTableViewCell.create(in: tableView, at: indexPath, with: viewModel)
            return appSettingsCell!
        case .account:
            accountCell = AccountMenuTableViewCell.create(in: tableView, at: indexPath, with: viewModel)
            return accountCell!
        case .help:
            helpCell = AccountMenuTableViewCell.create(in: tableView, at: indexPath, with: viewModel)
            return helpCell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .notifications:
            if indexPath.row == 0 {
                viewModel.menuItems[section.rawValue].isExpanded = !(viewModel.menuItems[section.rawValue].isExpanded ?? false)
                
                tableView.reloadSections([section.rawValue], with: .none)
                
                if viewModel.menuItems[section.rawValue].isExpanded ?? false {
//                    let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.hexColor("b3b3b3"))
//                    notificationCell?.accessoryView = UIImageView(image: image)
                    tableView.isScrollEnabled = true
                } else {
//                    let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.hexColor("b3b3b3"))
//                    notificationCell?.accessoryView = UIImageView(image: image)
                    tableView.isScrollEnabled = false
                }
            } else {
                print("tapped \(indexPath.row)")
            }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        return view
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

//
//  ProfileSettingTableViewDataSource.swift
//  netflix
//
//  Created by Developer on 24/08/2023.
//

import UIKit

// MARK: - ProfileSettingTableViewDataSource Type

final class ProfileSettingTableViewDataSource: TableViewDataSource {
    private let viewModel: ProfileViewModel
    
    init(with viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return viewModel.profileSettings.count
    }
    
    override func numberOfRows(in section: Int) -> Int {
        return 1
    }
    
    override func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell {
        return ProfileSettingTableViewCell.create(of: ProfileSettingTableViewCell.self,
                                                  on: tableView,
                                                  for: indexPath,
                                                  with: viewModel) as! T
    }
    
    override func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    override func viewForFooter(in section: Int) -> UIView? {
        return createDummyView()
    }
    
    override func heightForFooter(in section: Int) -> CGFloat {
        return 8.0
    }
}

// MARK: - Section Type

extension ProfileSettingTableViewDataSource {
    enum Section: Int {
        case notifications
        case myList
        case appSettings
        case account
        case help
    }
}

// MARK: - Private Implementation

extension ProfileSettingTableViewDataSource {
    private func createDummyView() -> UIView {
        let view = UIView(frame: CGRect(x: .zero, y: .zero, width: 414, height: 8.0))
        view.backgroundColor = .clear
        return view
    }
}

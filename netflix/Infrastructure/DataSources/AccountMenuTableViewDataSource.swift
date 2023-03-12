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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return AccountMenuTableViewCell.create(in: tableView, at: indexPath, with: viewModel)
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

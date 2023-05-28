//
//  TableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/05/2023.
//

import UIKit

// MARK: - TableViewDataSourceProtocol Type

private protocol TableViewDataSourceProtocol {
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell
    func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    func didSelectRow(in tableView: UITableView, at indexPath: IndexPath)
    func willDisplayCellForRow(_ cell: UITableViewCell, at indexPath: IndexPath)
    func viewForHeader(in tableView: UITableView, at section: Int) -> UIView?
    func heightForHeader(in section: Int) -> CGFloat
    func viewForFooter(in section: Int) -> UIView?
    func heightForFooter(in section: Int) -> CGFloat
    func tableViewDidScroll(_ scrollView: UIScrollView)
}

// MARK: - TableViewDataSource Type

class TableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // MARK:  UITableViewDelegate & UITableViewDataSource Implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayCellForRow(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeader(in: tableView, at: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooter(in: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooter(in: section)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableViewDidScroll(scrollView)
    }
    
    // MARK: TableViewDataSourceProtocol Implementation
    
    func numberOfSections() -> Int {
        return .zero
    }
    
    func numberOfRows(in section: Int) -> Int {
        return .zero
    }
    
    func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell {
        return T()
    }
    
    func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return .zero
    }
    
    func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {}
    
    func willDisplayCellForRow(_ cell: UITableViewCell, at indexPath: IndexPath) {}
    
    func viewForHeader(in tableView: UITableView, at section: Int) -> UIView? {
        return nil
    }
    
    func heightForHeader(in section: Int) -> CGFloat {
        return .zero
    }
    
    func viewForFooter(in section: Int) -> UIView? {
        return nil
    }
    
    func heightForFooter(in section: Int) -> CGFloat {
        return .zero
    }
    
    func tableViewDidScroll(_ scrollView: UIScrollView) {}
}

// MARK: - TableViewDataSourceProtocol Implementation

extension TableViewDataSource: TableViewDataSourceProtocol {}


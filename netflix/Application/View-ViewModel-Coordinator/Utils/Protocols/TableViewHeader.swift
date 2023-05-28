//
//  TableViewHeader.swift
//  netflix
//
//  Created by Zach Bazov on 21/02/2023.
//

import UIKit

// MARK: - TableViewHeader Type

protocol TableViewHeader: UITableViewHeaderFooterView, ViewLifecycleBehavior {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! { get set }
    
    func setTitle(_ string: String)
}

// MARK: - TableViewHeader Implementation

extension TableViewHeader {
    static func create<U>(
        of type: U.Type,
        on tableView: UITableView,
        for index: Int,
        with viewModel: HomeViewModel) -> U where U: UITableViewHeaderFooterView {
            
            tableView.register(headerFooter: U.self)
            
            guard let cell = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: reuseIdentifier) as? U
            else { fatalError() }
            
            switch cell {
            case let cell as LabeledTableHeaderView:
                cell.viewModel = LabeledTableHeaderViewModel(index: index, with: viewModel)
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
}

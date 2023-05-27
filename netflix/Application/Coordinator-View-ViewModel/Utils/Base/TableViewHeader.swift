//
//  TableViewHeader.swift
//  netflix
//
//  Created by Zach Bazov on 21/02/2023.
//

import UIKit

// MARK: - TableViewHeader Type

class TableViewHeader<T>: UITableViewHeaderFooterView where T: ViewModel {
    var viewModel: T!
    
    class func create<U>(
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
    
    deinit {
        viewModel = nil
        
        removeFromSuperview()
    }
    
    func viewDidLoad() {}
    func viewHierarchyWillConfigure() {}
    func viewWillConfigure() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension TableViewHeader: ViewLifecycleBehavior {}

//
//  TableHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 21/02/2023.
//

import UIKit

// MARK: - TableHeaderView Type

class TableHeaderView<T>: UITableViewHeaderFooterView where T: ViewModel {
    var viewModel: T!
    
    class func create<U>(
        of type: U.Type,
        on tableView: UITableView,
        for index: Int,
        with viewModel: HomeViewModel) -> U {
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

extension TableHeaderView: ViewLifecycleBehavior {}

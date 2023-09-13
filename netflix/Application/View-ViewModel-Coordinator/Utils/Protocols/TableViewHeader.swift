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
    static func create<U, CVM>(
        of type: U.Type,
        on tableView: UITableView,
        for index: Int,
        with viewModel: CVM) -> U where U: UITableViewHeaderFooterView, CVM: ViewModel {
            
            tableView.register(headerFooter: U.self)
            
            guard let cell = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: reuseIdentifier) as? U
            else { fatalError() }
            
            switch cell {
            case let cell as LabeledTableHeaderView:
                guard let viewModel = viewModel as? HomeViewModel else { fatalError() }
                
                cell.viewModel = LabeledTableHeaderViewModel(index: index, with: viewModel)
                cell.viewDidLoad()
            case let cell as MyNetflixNavigationTableHeaderView:
                guard let viewModel = viewModel as? MyNetflixViewModel else { fatalError() }
                
                let item = viewModel.menuItems[index]
                
                cell.index = index
                cell.viewModel = MyNetflixNavigationTableHeaderViewModel(item: item, with: viewModel)
                cell.viewDidLoad()
            case let cell as ReferrableTableHeaderView:
                guard let viewModel = viewModel as? MyNetflixViewModel else { fatalError() }
                
                let item = viewModel.menuItems[index]
                
                cell.index = index
                cell.viewModel = ReferrableTableHeaderViewModel(with: item, with: viewModel)
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
}

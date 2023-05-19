//
//  TableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/05/2023.
//

import UIKit

// MARK: - TableViewCell Type

class TableViewCell<T>: UITableViewCell where T: ViewModel {
    var viewModel: T!
    
    class func create<U>(
        of type: U.Type,
        on tableView: UITableView,
        for indexPath: IndexPath,
        with viewModel: HomeViewModel) -> U {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: U.self),
                for: indexPath) as? U
            else { fatalError() }
            
            switch cell {
            case let cell as ShowcaseTableViewCell:
                cell.viewModel = ShowcaseTableViewCellViewModel(with: viewModel)
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
    
    func viewDidLoad() {}
    func viewWillDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewWillConfigure() {}
    func viewWillDeallocate() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension TableViewCell: ViewLifecycleBehavior {}

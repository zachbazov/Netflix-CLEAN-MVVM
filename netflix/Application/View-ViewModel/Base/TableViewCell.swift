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
    
    class func create<U, V>(
        of type: U.Type,
        on tableView: UITableView,
        for indexPath: IndexPath,
        with viewModel: V) -> U where U: UITableViewCell {
            
            tableView.register(class: U.self)
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: U.self),
                for: indexPath) as? U
            else { fatalError() }
            
            switch cell {
            case let cell as ShowcaseTableViewCell:
                guard let viewModel = viewModel as? HomeViewModel else { fatalError() }
                
                cell.viewModel = ShowcaseTableViewCellViewModel(with: viewModel)
                cell.viewDidLoad()
            case let cell as DetailInfoTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as DetailDescriptionTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as DetailPanelTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as DetailNavigationTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as DetailCollectionTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
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
    func viewWillDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewWillConfigure() {}
    func viewWillDeallocate() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension TableViewCell: ViewLifecycleBehavior {}

//
//  TableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/05/2023.
//

import UIKit

// MARK: - TableViewCell Type

protocol TableViewCell: UITableViewCell, ViewLifecycleBehavior {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! { get set }
}

// MARK: - TableViewCell Implementation

extension TableViewCell {
    static func create<U, V>(
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
            case let cell as InfoTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as DescriptionTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as PanelTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            case let cell as NavigationTableViewCell:
                guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
                
                cell.viewModel = viewModel
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
}

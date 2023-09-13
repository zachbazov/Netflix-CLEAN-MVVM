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
            
            switch U.reuseIdentifier {
            case ProfileSettingTableViewCell.reuseIdentifier:
                tableView.register(nib: U.self)
            default:
                tableView.register(class: U.self)
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: U.reuseIdentifier,
                                                           for: indexPath) as? U
            else { fatalError() }
            
            switch (cell, viewModel) {
            case (let cell as ShowcaseTableViewCell, let controllerViewModel as HomeViewModel):
                let cellViewModel = ShowcaseTableViewCellViewModel(with: controllerViewModel)
                
                cell.viewModel = cellViewModel
                cell.viewDidLoad()
            case (let cell as InfoTableViewCell, let controllerViewModel as DetailViewModel):
                cell.viewModel = controllerViewModel
                cell.viewDidLoad()
            case (let cell as DescriptionTableViewCell, let controllerViewModel as DetailViewModel):
                cell.viewModel = controllerViewModel
                cell.viewDidLoad()
            case (let cell as PanelTableViewCell, let controllerViewModel as DetailViewModel):
                cell.viewModel = controllerViewModel
                cell.viewDidLoad()
            case (let cell as NavigationTableViewCell, let controllerViewModel as DetailViewModel):
                cell.viewModel = controllerViewModel
                cell.viewDidLoad()
            case (let cell as NavigationOverlayTableViewCell, let controllerViewModel as NavigationOverlayViewModel):
                let model = controllerViewModel.items[indexPath.row]
                let cellViewModel = NavigationOverlayCollectionViewCellViewModel(title: model.stringValue)
                
                cell.viewModel = cellViewModel
                cell.viewDidLoad()
            case (let cell as ProfileSettingTableViewCell, let controllerViewModel as ProfileViewModel):
                let cellViewModel = ProfileSettingTableViewCellViewModel(at: indexPath, with: controllerViewModel)
                
                cell.indexPath = indexPath
                cell.profileViewModel = controllerViewModel
                cell.viewModel = cellViewModel
                cell.viewDidLoad()
            case (let cell as MyNetflixProfileTableViewCell, let controllerViewModel as MyNetflixViewModel):
                let cellViewModel = MyNetflixProfileTableViewCellViewModel(with: controllerViewModel)
                
                cell.viewModel = cellViewModel
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
}

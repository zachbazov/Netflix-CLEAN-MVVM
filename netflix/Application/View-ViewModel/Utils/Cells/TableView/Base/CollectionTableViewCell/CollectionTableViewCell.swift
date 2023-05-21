//
//  CollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 20/05/2023.
//

import UIKit

// MARK: - CollectionTavleViewCellProtocol Type

protocol CollectionTableViewCellProtocol {
    
}

// MARK: - CollectionTableViewCell Type

class CollectionTableViewCell: UITableViewCell {
    
    class func create<T, VM>(of type: T.Type,
                             on tableView: UITableView,
                             for indexPath: IndexPath,
                             with viewModel: VM) -> HomeCollectionTableViewCell<T>
    where T: UICollectionViewCell, VM: ViewModel {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HomeCollectionTableViewCell<T>.reuseIdentifier,
            for: indexPath) as? HomeCollectionTableViewCell<T>,
              let index = HomeTableViewDataSource.Index(rawValue: indexPath.section)
        else { fatalError() }
        
        switch viewModel {
        case let viewModel as HomeViewModel:
            let section = viewModel.section(at: index)
            
            cell.viewModel = CollectionTableViewCellViewModel(section: section, with: viewModel)
            cell.viewDidLoad()
        default: break
        }
        
        return cell
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionTableViewCell: ViewLifecycleBehavior {}

// MARK: - CollectionTableViewCellProtocol Implementation

extension CollectionTableViewCell: CollectionTableViewCellProtocol {}

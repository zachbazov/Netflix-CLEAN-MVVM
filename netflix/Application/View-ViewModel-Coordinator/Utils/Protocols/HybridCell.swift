//
//  HybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 20/05/2023.
//

import UIKit

// MARK: - HybridCell Type

protocol HybridCell: UITableViewCell, ViewLifecycleBehavior, ViewObservable {
    associatedtype CellType: UICollectionViewCell
    associatedtype DataSourceType: UICollectionViewDataSource
    associatedtype ViewModelType: ViewModel
    associatedtype ControllerViewModelType: ViewModel
    
    var collectionView: UICollectionView { get set }
    var cell: CellType? { get set }
    var dataSource: DataSourceType? { get set }
    var viewModel: ViewModelType? { get set }
    var controllerViewModel: ControllerViewModelType? { get set }
    var layout: CollectionViewLayout? { get set }
    
    func createCollectionView() -> UICollectionView
    func createDataSource()
    func createDataSource() -> DataSourceType?
    func createLayout()
    func createLayout() -> CollectionViewLayout?
}

// MARK: - HybridCell Implementation

extension HybridCell {
    func createCollectionView() -> UICollectionView { return UICollectionView() }
    func createDataSource() {}
    func createDataSource() -> DataSourceType? { return nil }
    func createLayout() {}
    func createLayout() -> CollectionViewLayout? { return nil }
    
    static func create<T>(
        expecting cell: T.Type,
        embedding type: CellType.Type,
        on tableView: UITableView,
        for indexPath: IndexPath,
        with viewModel: ControllerViewModelType) -> T where T: UITableViewCell {
            
            tableView.register(class: T.self)
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: T.reuseIdentifier,
                for: indexPath) as? T
            else { fatalError() }
            
            switch viewModel {
            case let viewModel as HomeViewModel:
                guard let cell = cell as? MediaHybridCell<CellType>,
                      let index = MediaTableViewDataSource.Index(rawValue: indexPath.section)
                else { fatalError() }
                
                let section = viewModel.section(at: index)
                
                cell.controllerViewModel = viewModel
                cell.viewModel = MediaHybridCellViewModel(section: section, with: viewModel)
                cell.viewDidLoad()
            case let viewModel as AccountViewModel:
                guard let cell = cell as? AccountMenuNotificationHybridCell else { fatalError() }
                
                let item = viewModel.menuItems[indexPath.section]
                
                cell.controllerViewModel = viewModel
                cell.viewModel = AccountMenuNotificationHybridCellViewModel(with: item, for: indexPath)
                cell.viewDidLoad()
            case let viewModel as DetailViewModel:
                guard let cell = cell as? DetailHybridCell else { fatalError() }
                
                cell.controllerViewModel = viewModel
                cell.viewModel = DetailHybridCellViewModel(with: viewModel)
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
}

// MARK: - Internal Implementation

extension HybridCell {
    func setLayout() {
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

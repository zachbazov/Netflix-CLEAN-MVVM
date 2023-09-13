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
            
            switch (cell, viewModel) {
            case (let cell as MediaHybridCell<CellType>, let controllerViewModel as HomeViewModel):
                guard let index = MediaTableViewDataSource.Index(rawValue: indexPath.section) else { fatalError() }
                
                let section = controllerViewModel.section(at: index)
                
                cell.controllerViewModel = controllerViewModel
                cell.viewModel = MediaHybridCellViewModel(section: section, with: controllerViewModel)
                cell.viewDidLoad()
            case (let cell as NotificationHybridCell, let controllerViewModel as MyNetflixViewModel):
                let item = controllerViewModel.menuItems[indexPath.section]
                
                cell.controllerViewModel = controllerViewModel
                cell.viewModel = NotificationHybridCellViewModel(with: item, for: indexPath)
                cell.viewDidLoad()
            case (let cell as DetailHybridCell, let controllerViewModel as DetailViewModel):
                cell.controllerViewModel = controllerViewModel
                cell.viewModel = DetailHybridCellViewModel(with: controllerViewModel)
                cell.viewDidLoad()
            case (let cell as MyListHybridCell, let controllerViewModel as MyNetflixViewModel):
                let cellViewModel = MyListHybridCellViewModel(indexPath: indexPath)
                
                cell.controllerViewModel = controllerViewModel
                cell.viewModel = cellViewModel
                cell.viewDidLoad()
            case (let cell as TrailerHybridCell, let controllerViewModel as MyNetflixViewModel):
                let cellViewModel = TrailerHybridCellViewModel(indexPath: indexPath)
                
                cell.controllerViewModel = controllerViewModel
                cell.viewModel = cellViewModel
                cell.viewDidLoad()
            default:
                fatalError("Unexpected cell type: \(T.self)")
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

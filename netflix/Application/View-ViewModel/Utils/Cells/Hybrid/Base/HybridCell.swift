//
//  HybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 20/05/2023.
//

import UIKit

protocol HybridCellProtocol {}

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    associatedtype Cell: UICollectionViewCell
    associatedtype DataSource: UICollectionViewDataSource
    associatedtype VM: ViewModel
    associatedtype CVM: ViewModel
    
    var collectionView: UICollectionView { get }
    var dataSource: DataSource? { get }
    var viewModel: VM? { get }
    var controllerViewModel: CVM? { get }
    var layout: CollectionViewLayout? { get }
}

// MARK: - HybridCell Type

class HybridCell<Cell, DataSource, VM, CVM>: UITableViewCell where Cell: UICollectionViewCell,
                                                                                DataSource: UICollectionViewDataSource,
                                                                                VM: ViewModel,
                                                                                CVM: ViewModel {
    lazy var collectionView: UICollectionView = createCollectionView()
    var dataSource: DataSource?
    var viewModel: VM?
    var controllerViewModel: CVM?
    var layout: CollectionViewLayout?
    
    class func create(
        of type: Cell.Type,
        on tableView: UITableView,
        for indexPath: IndexPath,
        with viewModel: CVM) -> MediaHybridCell<Cell> {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MediaHybridCell<Cell>.reuseIdentifier,
                for: indexPath) as? MediaHybridCell<Cell>
            else { fatalError() }
            
            switch viewModel {
            case let viewModel as HomeViewModel:
                guard let index = HomeTableViewDataSource.Index(rawValue: indexPath.section) else { fatalError() }
                
                let section = viewModel.section(at: index)
                
                cell.controllerViewModel = viewModel
                cell.viewModel = CollectionTableViewCellViewModel(section: section, with: viewModel)
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
    
    class func create<T>(
        expecting cell: T.Type,
        embedding type: Cell.Type,
        on tableView: UITableView,
        for indexPath: IndexPath,
        with viewModel: CVM) -> T where T: UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: T.reuseIdentifier,
                for: indexPath) as? T
            else { fatalError() }
            
            switch viewModel {
            case let viewModel as AccountViewModel:
                guard let cell = cell as? MediaNotificationHybridCell else { fatalError() }
                
                let model = viewModel.menuItems[indexPath.section]
                
                cell.controllerViewModel = viewModel
                cell.viewModel = MediaNotificationHybridCellViewModel(with: model, for: indexPath)
                cell.viewDidLoad()
                break
            default: break
            }
            
            return cell
        }
    
    deinit {
        printIfDebug(.action, "deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewWillDeallocate()
    }
    
    func viewDidLoad() {}
    func viewWillDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewWillConfigure() {}
    func viewWillDeallocate() {}
    
    func createCollectionView() -> UICollectionView { return UICollectionView() }
    func createDataSource() {}
    func createLayout() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension HybridCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension HybridCell: ViewProtocol {
    func setLayout() {
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

// MARK: - HybridCellProtocol Implementation

extension HybridCell: HybridCellProtocol {}

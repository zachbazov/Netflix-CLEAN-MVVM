//
//  CollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 20/05/2023.
//

import UIKit

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

// MARK: - CollectionTableViewCell Type

class CollectionTableViewCell<Cell, DataSource, VM, CVM>: UITableViewCell where Cell: UICollectionViewCell,
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
        with viewModel: CVM) -> HybridCell<Cell> {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HybridCell<Cell>.reuseIdentifier,
                for: indexPath) as? HybridCell<Cell>
            else { fatalError() }
            
            switch viewModel {
            case let viewModel as HomeViewModel:
                guard let index = HomeTableViewDataSource.Index(rawValue: indexPath.section) else { fatalError() }
                
                let section = viewModel.section(at: index)
                
                cell.controllerViewModel = viewModel
                cell.viewModel = CollectionTableViewCellViewModel(section: section, with: viewModel)
                cell.viewDidLoad()
            case let viewModel as AccountViewModel:
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
    
    func createDataSource() {}
    func createLayout() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionTableViewCell: ViewLifecycleBehavior {}

// MARK: - CollectionTableViewCellProtocol Implementation

extension CollectionTableViewCell: ViewProtocol {
    fileprivate func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(Cell.self)
        return collectionView
    }
    
    func setLayout() {
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

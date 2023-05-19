//
//  CollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - Cell Types

typealias RatedTableViewCell = CollectionTableViewCell<RatedCollectionViewCell>
typealias ResumableTableViewCell = CollectionTableViewCell<ResumableCollectionViewCell>
typealias StandardTableViewCell = CollectionTableViewCell<StandardCollectionViewCell>
typealias BlockbusterTableViewCell = CollectionTableViewCell<BlockbusterCollectionViewCell>

// MARK: - ViewInput Type

private protocol ViewProtocol {
    associatedtype T: UICollectionViewCell
    
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> CollectionTableViewCell<T>
    
    var collectionView: UICollectionView { get }
    var dataSource: HomeCollectionViewDataSource<T>? { get }
    var layout: CollectionViewLayout? { get }
    var viewModel: CollectionTableViewCellViewModel? { get }
    
    func createCollectionView() -> UICollectionView
    func createDataSource()
    func createLayout()
    func setLayout()
    func layoutWillChange(with viewModel: CollectionTableViewCellViewModel)
}

// MARK: - CollectionTableViewCell<T> Type

class CollectionTableViewCell<T>: UITableViewCell where T: UICollectionViewCell {
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: HomeCollectionViewDataSource<T>?
    fileprivate var layout: CollectionViewLayout?
    fileprivate var viewModel: CollectionTableViewCellViewModel?
    
    /// Create a table view cell which holds a collection view.
    /// - Parameters:
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> CollectionTableViewCell<T> {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CollectionTableViewCell<T>.reuseIdentifier,
            for: indexPath) as? CollectionTableViewCell<T>,
              let index = HomeTableViewDataSource.Index(rawValue: indexPath.section)
        else { fatalError() }
        
        let section = viewModel.section(at: index)
        
        cell.viewModel = CollectionTableViewCellViewModel(section: section, with: viewModel)
        cell.viewDidLoad()
        
        return cell
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    func viewWillDeallocate() {
        collectionView.removeFromSuperview()
        
        dataSource = nil
        layout = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension CollectionTableViewCell: ViewProtocol {
    fileprivate func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(T.self)
        return collectionView
    }
    
    func createDataSource() {
        guard let viewModel = viewModel,
              let homeViewModel = viewModel.coordinator.viewController?.viewModel
        else { return }
        
        dataSource = HomeCollectionViewDataSource(on: collectionView, section: viewModel.section, viewModel: homeViewModel)
    }
    
    func createLayout() {
        guard let viewModel = viewModel else { return }
        
        layoutWillChange(with: viewModel)
    }
    
    fileprivate func setLayout() {
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    /// Setting a layout for the collection view.
    /// - Parameters:
    ///   - section: A section object that represent the cell.
    ///   - viewModel: Coordinating view model.
    fileprivate func layoutWillChange(with viewModel: CollectionTableViewCellViewModel) {
        guard let indices = HomeTableViewDataSource.Index(rawValue: viewModel.section.id) else { return }
        
        switch indices {
        case .display:
            return
        case .rated:
            layout = CollectionViewLayout(layout: .rated, scrollDirection: .horizontal)
        case .blockbuster:
            layout = CollectionViewLayout(layout: .blockbuster, scrollDirection: .horizontal)
        default:
            layout = CollectionViewLayout(layout: .standard, scrollDirection: .horizontal)
        }
        
        setLayout()
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionTableViewCell: ViewLifecycleBehavior {}

// MARK: - SortOptions Type

extension CollectionTableViewCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}

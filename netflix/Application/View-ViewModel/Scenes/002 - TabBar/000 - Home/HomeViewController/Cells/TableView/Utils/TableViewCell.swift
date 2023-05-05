//
//  TableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - Cell Types

typealias RatedTableViewCell = TableViewCell<RatedCollectionViewCell>
typealias ResumableTableViewCell = TableViewCell<ResumableCollectionViewCell>
typealias StandardTableViewCell = TableViewCell<StandardCollectionViewCell>
typealias BlockbusterTableViewCell = TableViewCell<BlockbusterCollectionViewCell>

// MARK: - ViewInput Type

private protocol ViewProtocol {
    associatedtype T: UICollectionViewCell
    
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> TableViewCell<T>
    
    var collectionView: UICollectionView { get }
    var dataSource: HomeCollectionViewDataSource<T>? { get }
    var layout: CollectionViewLayout? { get }
    var viewModel: TableViewCellViewModel? { get }
    
    func createCollectionView() -> UICollectionView
    func createDataSource()
    func createLayout()
    func layoutDidChange(with viewModel: TableViewCellViewModel)
    func setLayout()
}

// MARK: - TableViewCell<T> Type

class TableViewCell<T>: UITableViewCell where T: UICollectionViewCell {
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: HomeCollectionViewDataSource<T>?
    fileprivate var layout: CollectionViewLayout?
    fileprivate var viewModel: TableViewCellViewModel?
    
    /// Create a table view cell which holds a collection view.
    /// - Parameters:
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> TableViewCell<T> {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TableViewCell<T>.reuseIdentifier, for: indexPath) as? TableViewCell<T>,
              let index = HomeTableViewDataSource.Index(rawValue: indexPath.section)
        else { fatalError() }
        
        let section = viewModel.section(at: index)
        
        cell.viewModel = TableViewCellViewModel(section: section, with: viewModel)
        
        cell.viewDidLoad()
        
        return cell
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        collectionView.removeFromSuperview()
        
        dataSource = nil
        layout = nil
        viewModel = nil
    }
    
    func viewDidLoad() {
        viewDidConfigure()
        viewDidDeploySubviews()
    }
    
    func viewDidConfigure() {
        backgroundColor = .clear
    }
    
    func viewDidDeploySubviews() {
        createDataSource()
        createLayout()
    }
}

// MARK: - ViewProtocol Implementation

extension TableViewCell: ViewProtocol {
    fileprivate func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(T.self)
        contentView.addSubview(collectionView)
        collectionView.constraintToSuperview(contentView)
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
        
        layoutDidChange(with: viewModel)
    }
    
    /// Setting a layout for the collection view.
    /// - Parameters:
    ///   - section: A section object that represent the cell.
    ///   - viewModel: Coordinating view model.
    fileprivate func layoutDidChange(with viewModel: TableViewCellViewModel) {
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
    
    fileprivate func setLayout() {
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension TableViewCell: ViewLifecycleBehavior {}

// MARK: - SortOptions Type

extension TableViewCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}

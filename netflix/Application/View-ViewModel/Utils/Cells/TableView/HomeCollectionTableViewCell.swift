//
//  CollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - ViewInput Type

private protocol ViewProtocol {
    associatedtype T: UICollectionViewCell
    
//    static func create(on tableView: UITableView,
//                       for indexPath: IndexPath,
//                       with viewModel: HomeViewModel) -> HomeCollectionTableViewCell<T>
    
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

// MARK: - HomeCollectionTableViewCell Type

class HomeCollectionTableViewCell<T>: CollectionTableViewCell where T: UICollectionViewCell {
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: HomeCollectionViewDataSource<T>?
    fileprivate var layout: CollectionViewLayout?
    var viewModel: CollectionTableViewCellViewModel?
    
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

extension HomeCollectionTableViewCell: ViewProtocol {
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

// MARK: - SortOptions Type

extension HomeCollectionTableViewCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}

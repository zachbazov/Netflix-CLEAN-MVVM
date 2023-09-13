//
//  MyListHybridCell.swift
//  netflix
//
//  Created by Developer on 12/09/2023.
//

import UIKit

// MARK: - MyListHybridCell Type

final class MyListHybridCell: UITableViewCell {
    lazy var collectionView: UICollectionView = createCollectionView()
    
    var cell: StandardCollectionViewCell?
    var dataSource: MyListCollectionViewDataSource<MyNetflixViewModel>?
    var viewModel: MyListHybridCellViewModel?
    var controllerViewModel: MyNetflixViewModel?
    var layout: CollectionViewLayout?
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
        viewDidDeallocate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

// MARK: - TableViewCell Implementation

extension MyListHybridCell: HybridCell {
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
        cell?.removeFromSuperview()
        
        cell = nil
        dataSource = nil
        viewModel = nil
        controllerViewModel = nil
        layout = nil
        
        removeFromSuperview()
    }
}

// MARK: - Private Implementation

extension MyListHybridCell {
    func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(StandardCollectionViewCell.self)
        return collectionView
    }
    
    func createDataSource() {
        guard let controllerViewModel = controllerViewModel else { return }
        
        dataSource = MyListCollectionViewDataSource(collectionView: collectionView, with: controllerViewModel)
    }
    
    func createLayout() {
        layout = CollectionViewLayout(layout: .standard, scrollDirection: .horizontal)
        
        guard let layout = layout else { fatalError() }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        dataSource?.dataSourceDidChange()
    }
}

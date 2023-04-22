//
//  BrowseOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var collectionView: UICollectionView { get }
    var dataSource: BrowseOverlayCollectionViewDataSource? { get }
    
    func createCollectionView() -> UICollectionView
    func dataSourceDidChange()
}

// MARK: - BrowseOverlayView Type

final class BrowseOverlayView: View<BrowseOverlayViewModel> {
    private(set) lazy var collectionView: UICollectionView = createCollectionView()
    
    var dataSource: BrowseOverlayCollectionViewDataSource? {
        didSet { dataSourceDidChange() }
    }
    
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        
        self.viewModel = BrowseOverlayViewModel(with: viewModel)
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        parent.isHidden(true)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewProtocol Implementation

extension BrowseOverlayView: ViewProtocol {
    fileprivate func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .navigationOverlay, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.register(StandardCollectionViewCell.nib,
                                forCellWithReuseIdentifier: StandardCollectionViewCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.backgroundColor = .black
        addSubview(collectionView)
        return collectionView
    }
    
    fileprivate func dataSourceDidChange() {
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
}

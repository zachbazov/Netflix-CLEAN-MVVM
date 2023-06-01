//
//  NewsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - NewsViewController Type

final class NewsViewController: UIViewController, Controller {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private(set) var collectionViewContainer: UIView!
    
    var viewModel: NewsViewModel!
    
    fileprivate lazy var navigationView: NewsNavigationView? = createNavigationView()
    fileprivate(set) lazy var collectionView: UICollectionView? = createCollectionView()
    fileprivate lazy var dataSource: NewsCollectionViewDataSource? = createDataSource()
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHierarchyWillConfigure()
        viewDidBindObservers()
        viewModel.viewDidLoad()
    }
    
    func viewHierarchyWillConfigure() {
        navigationView?
            .addToHierarchy(on: navigationViewContainer)
            .constraintToSuperview(navigationViewContainer)
        
        collectionView?
            .addToHierarchy(on: collectionViewContainer)
            .constraintToSuperview(collectionViewContainer)
    }
    
    func viewDidBindObservers() {
        viewModel.items.observe(on: self) { [weak self] _ in
            guard let self = self,
                  !self.viewModel.isEmpty
            else { return }
            
            self.dataSource?.dataSourceDidChange()
        }
    }
    
    func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.items.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    func viewWillDeallocate() {
        viewDidUnbindObservers()
        
        viewModel?.coordinator = nil
        viewModel = nil
        
        dataSource = nil
        collectionView?.removeFromSuperview()
        collectionView = nil
        
        navigationView?.removeFromSuperview()
        navigationView = nil
        
        removeFromParent()
    }
}

// MARK: - Private Implementation

extension NewsViewController {
    private func createNavigationView() -> NewsNavigationView {
        return NewsNavigationView()
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .news, scrollDirection: .vertical)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setBackgroundColor(.black)
        
        return collectionView
    }
    
    private func createDataSource() -> NewsCollectionViewDataSource {
        return NewsCollectionViewDataSource(with: viewModel)
    }
}

//
//  MyListViewController.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import UIKit

// MARK: - MyListViewController Type

final class MyListViewController: UIViewController, Controller {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: MyListCollectionViewDataSource<MyListViewModel>?
    
    var viewModel: MyListViewModel!
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDeallocate()
    }
    
    func viewDidDeploySubviews() {
        createDataSource()
    }
    
    func viewDidDeallocate() {
        viewModel?.coordinator?.viewController = nil
        viewModel?.coordinator = nil
        viewModel = nil
        
        navigationController?.viewControllers.removeAll()
        removeFromParent()
    }
}

// MARK: - Private Implementation

extension MyListViewController {
    private func createDataSource() {
        let layout = CollectionViewLayout(layout: .navigationOverlay, scrollDirection: .vertical)
        
        dataSource = MyListCollectionViewDataSource(collectionView: collectionView, with: viewModel)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        dataSource?.dataSourceDidChange()
    }
}

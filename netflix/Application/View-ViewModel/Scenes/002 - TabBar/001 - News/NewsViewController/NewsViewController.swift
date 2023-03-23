//
//  NewsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerProtocol {
    var navigationView: NewsNavigationView! { get }
    var collectionView: UICollectionView! { get }
    var dataSource: NewsCollectionViewDataSource! { get }
}

// MARK: - NewsViewController Type

final class NewsViewController: Controller<NewsViewModel> {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private(set) var tableViewContainer: UIView!
    
    fileprivate var navigationView: NewsNavigationView!
    fileprivate(set) var collectionView: UICollectionView!
    fileprivate var dataSource: NewsCollectionViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidBindObservers()
        viewModel.viewDidLoad()
    }
    
    override func viewDidDeploySubviews() {
        setupNavigationView()
        setupCollectionView()
        setupDataSource()
    }
    
    override func viewDidBindObservers() {
        viewModel.items.observe(on: self) { [weak self] _ in
            guard let self = self, !self.viewModel.isEmpty else { return }
            self.dataSource.dataSourceDidChange()
        }
    }
    
    override func viewDidUnbindObservers() {
        if let viewModel = viewModel {
            printIfDebug(.success, "Removed `NewsViewModel` observers.")
            viewModel.items.remove(observer: self)
        }
    }
}

// MARK: - ControllerProtocol Implementation

extension NewsViewController: ControllerProtocol {}

// MARK: - Private UI Implementation

extension NewsViewController {
    private func setupNavigationView() {
        navigationView = NewsNavigationView(on: navigationViewContainer)
    }
    
    private func setupCollectionView() {
        let layout = CollectionViewLayout(layout: .news, scrollDirection: .vertical)
        collectionView = UICollectionView(frame: tableViewContainer.bounds, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(NewsCollectionViewCell.self)
        collectionView.backgroundColor = .black
        
        tableViewContainer.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = NewsCollectionViewDataSource(with: viewModel)
    }
}

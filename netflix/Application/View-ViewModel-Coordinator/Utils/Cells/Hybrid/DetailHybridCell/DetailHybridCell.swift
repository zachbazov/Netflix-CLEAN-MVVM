//
//  DetailHybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 25/05/2023.
//

import UIKit

// MARK: - DetailHybridCell Type

final class DetailHybridCell: UITableViewCell {
    lazy var collectionView: UICollectionView = createCollectionView()
    
    var cell: DetailCollectionViewCell?
    var dataSource: DetailCollectionViewDataSource?
    var viewModel: DetailHybridCellViewModel?
    var controllerViewModel: DetailViewModel?
    var layout: CollectionViewLayout?
    
    deinit {
        viewWillDeallocate()
    }
}

// MARK: - HybridCell Implementation

extension DetailHybridCell: HybridCell {
    func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillBindObservers()
        viewModel?.dataWillLoad()
    }
    
    func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    func viewWillBindObservers() {
        viewModel?.season.observe(on: self) { [weak self] season in
            guard let self = self else { return }

            self.reloadRow()
        }

        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }

            self.reloadRow()
        }
    }

    func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }

        viewModel.season.remove(observer: self)
        viewModel.state.remove(observer: self)

        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        collectionView.removeFromSuperview()
        cell?.removeFromSuperview()
        
        cell = nil
        dataSource = nil
        layout = nil
        viewModel = nil
        controllerViewModel = nil
        
        removeFromSuperview()
    }
    
    func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.setBackgroundColor(.black)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 16.0, left: .zero, bottom: .zero, right: .zero)
        return collectionView
    }
    
    func createDataSource() -> DetailCollectionViewDataSource? {
        guard let controllerViewModel = controllerViewModel,
              let dataSource = controllerViewModel.coordinator?.viewController?.dataSource,
              let navigationView = dataSource.navigationCell?.navigationView
        else { fatalError() }
        
        controllerViewModel.items = viewModel?.setItems(for: navigationView.viewModel.state.value) ?? []
        
        return DetailCollectionViewDataSource(with: controllerViewModel)
    }
    
    func createLayout() -> CollectionViewLayout? {
        guard let controllerViewModel = controllerViewModel,
              let dataSource = controllerViewModel.coordinator?.viewController?.dataSource,
              let navigationView = dataSource.navigationCell?.navigationView
        else { fatalError() }
        
        switch navigationView.viewModel.state.value {
        case .episodes:
            return CollectionViewLayout(layout: .descriptive, scrollDirection: .vertical)
        case .trailers:
            return CollectionViewLayout(layout: .trailer, scrollDirection: .vertical)
        case .similarContent:
            return CollectionViewLayout(layout: .detail, scrollDirection: .vertical)
        }
    }
}

// MARK: - State Type

extension DetailHybridCell {
    enum State {
        case series
        case film
        case similarContent
    }
}

// MARK: - Internal Implementation

extension DetailHybridCell {
    func dataSourceDidChange() {
        dataSource = createDataSource()
        layout = createLayout()
        
        guard let dataSource = dataSource,
              let layout = layout
        else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
}

// MARK: - Private Implementation

extension DetailHybridCell {
    private func reloadRow() {
        guard let controller = viewModel?.coordinator.viewController,
              let dataSource = controller.dataSource
        else { return }
        
        mainQueueDispatch {
            dataSource.reloadRow(at: .collection)
        }
    }
}

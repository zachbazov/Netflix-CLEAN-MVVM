//
//  DetailHybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 25/05/2023.
//

import UIKit

// MARK: - DetailHybridCell Type

final class DetailHybridCell: HybridCell<DetailCollectionViewCell, DetailCollectionViewDataSource, DetailHybridCellViewModel, DetailViewModel> {
    
    deinit {
        viewWillDeallocate()
        super.viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillBindObservers()
        viewModel?.dataWillLoad()
    }
    
    override func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    override func viewWillBindObservers() {
        viewModel?.season.observe(on: self) { [weak self] season in
            guard let self = self else { return }

            self.reloadRow()
        }

        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }

            self.reloadRow()
        }
    }

    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }

        viewModel.season.remove(observer: self)
        viewModel.state.remove(observer: self)

        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        collectionView.removeFromSuperview()
        
        dataSource = nil
        layout = nil
        viewModel = nil
        controllerViewModel = nil
        
        removeFromSuperview()
    }
    
    override func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.setBackgroundColor(.black)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 16.0, left: .zero, bottom: .zero, right: .zero)
        return collectionView
    }
    
    override func createDataSource() -> DetailCollectionViewDataSource? {
        guard let controllerViewModel = controllerViewModel,
              let dataSource = controllerViewModel.coordinator?.viewController?.dataSource,
              let navigationView = dataSource.navigationCell?.navigationView
        else { fatalError() }
        
        controllerViewModel.items = viewModel?.setItems(for: navigationView.viewModel.state.value) ?? []
        
        return DetailCollectionViewDataSource(with: controllerViewModel)
    }
    
    override func createLayout() -> CollectionViewLayout? {
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

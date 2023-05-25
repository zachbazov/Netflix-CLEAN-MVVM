//
//  DetailTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var collectionCell: DetailHybridCell? { get }
    var navigationCell: NavigationTableViewCell? { get }
    
    func contentSize(for state: DetailNavigationView.State) -> CGFloat
    func reloadRow(at index: DetailTableViewDataSource.Index)
}

// MARK: - DetailTableViewDataSource Type

final class DetailTableViewDataSource: TableViewDataSource {
    
    fileprivate let coordinator: DetailViewCoordinator
    
    fileprivate(set) var navigationCell: NavigationTableViewCell?
    fileprivate(set) var collectionCell: DetailHybridCell?
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        super.init()
        
        self.dataSourceDidChange()
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        collectionCell?.removeFromSuperview()
        collectionCell = nil
        
        navigationCell?.removeFromSuperview()
        navigationCell = nil
    }
    
    override func numberOfSections() -> Int {
        return Index.allCases.count
    }
    
    override func numberOfRows(in section: Int) -> Int {
        return 1
    }
    
    override func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let viewModel = coordinator.viewController?.viewModel,
              let index = Index(rawValue: indexPath.section)
        else { fatalError() }
        
        switch index {
        case .info:
            return InfoTableViewCell.create(of: InfoTableViewCell.self,
                                            on: tableView,
                                            for: indexPath,
                                            with: viewModel) as! T
        case .description:
            return DescriptionTableViewCell.create(of: DescriptionTableViewCell.self,
                                                   on: tableView,
                                                   for: indexPath,
                                                   with: viewModel) as! T
        case .panel:
            return PanelTableViewCell.create(of: PanelTableViewCell.self,
                                             on: tableView,
                                             for: indexPath,
                                             with: viewModel) as! T
        case .navigation:
            navigationCell = NavigationTableViewCell.create(of: NavigationTableViewCell.self,
                                                            on: tableView,
                                                            for: indexPath,
                                                            with: viewModel)
            return navigationCell as! T
        case .collection:
            collectionCell = DetailHybridCell.create(expecting: DetailHybridCell.self,
                                                     embedding: DetailCollectionViewCell.self,
                                                     on: tableView,
                                                     for: indexPath,
                                                     with: viewModel)
            return collectionCell as! T
        }
    }
    
    @discardableResult
    override func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        guard let view = coordinator.viewController?.view as UIView?,
              let index = DetailTableViewDataSource.Index(rawValue: indexPath.section)
        else { return .zero }
        
        tableView.estimatedSectionFooterHeight = .zero
        tableView.estimatedSectionHeaderHeight = .zero
        
        switch index {
        case .info: return view.bounds.height * 0.21
        case .description: return view.bounds.height * 0.135
        case .panel: return view.bounds.height * 0.0764
        case .navigation: return view.bounds.height * 0.0764
        case .collection:
            guard let dataSource = coordinator.viewController?.dataSource,
                  let state = dataSource.navigationCell?.navigationView?.viewModel.state.value
            else { return .zero }
            
            return contentSize(for: state)
        }
    }
}

// MARK: - DataSourceProtocol Implementation

extension DetailTableViewDataSource: DataSourceProtocol {
    fileprivate func contentSize(for state: DetailNavigationView.State) -> CGFloat {
        let cellHeight: CGFloat
        let lineSpacing: CGFloat
        let itemsCount: CGFloat
        let itemsPerLine: CGFloat
        let topContentInset: CGFloat
        let roundedItemsOutput: CGFloat
        let value: CGFloat
        
        switch state {
        case .episodes:
            guard let season = collectionCell?.viewModel?.season.value else { return .zero }
            
            cellHeight = 156.0
            lineSpacing = 8.0
            itemsCount = CGFloat(season.episodes.count)
            value = cellHeight * itemsCount + (lineSpacing * itemsCount)
            
            return value
        case .trailers:
            guard let viewModel = coordinator.viewController?.viewModel,
                  let trailers = viewModel.media?.resources.trailers
            else { return .zero }
            
            cellHeight = 224.0
            lineSpacing = 8.0
            itemsCount = CGFloat(trailers.count)
            value = cellHeight * itemsCount + (lineSpacing * itemsCount)
            
            return value
        default:
            guard let viewModel = coordinator.viewController?.viewModel,
                  let media = viewModel.section?.media
            else { return .zero }
            
            cellHeight = 146.0
            lineSpacing = 8.0
            itemsPerLine = 3.0
            topContentInset = 16.0
            itemsCount = CGFloat(media.count)
            roundedItemsOutput = (itemsCount / itemsPerLine).rounded(.awayFromZero)
            value = roundedItemsOutput * cellHeight + lineSpacing * roundedItemsOutput + topContentInset
            
            return value
        }
    }
    
    func reloadRow(at index: DetailTableViewDataSource.Index) {
        guard let tableView = coordinator.viewController?.tableView else { return }
        
        switch index {
        case .collection:
            collectionCell?.dataSourceDidChange()
            
            let indexPath = IndexPath(row: index.rawValue, section: .zero)
            heightForRow(in: tableView, at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .fade)
        default: break
        }
    }
}

// MARK: - Index Type

extension DetailTableViewDataSource {
    /// Section's index representation type.
    enum Index: Int, CaseIterable {
        case info
        case description
        case panel
        case navigation
        case collection
    }
}

// MARK: - Private Implementation

extension DetailTableViewDataSource {
    private func createDummyView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    private func dataSourceDidChange() {
        guard let tableView = coordinator.viewController?.tableView else { return }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

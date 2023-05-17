//
//  DetailTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: DetailViewModel { get }
    var tableView: UITableView { get }
    var numberOfRows: Int { get }
    var numberOfSections: Int { get }
    
    var collectionCell: DetailCollectionTableViewCell? { get }
    var navigationCell: DetailNavigationTableViewCell? { get }
    
    func viewsDidRegister()
    func dataSourceDidChange()
    
    func contentSize(with state: DetailNavigationView.State) -> Float
    func reloadRow(at index: DetailTableViewDataSource.Index)
    func heightForRow(at index: DetailTableViewDataSource.Index)
    func reloadData(at index: DetailTableViewDataSource.Index)
}

// MARK: - DetailTableViewDataSource Type

final class DetailTableViewDataSource: NSObject {
    fileprivate let viewModel: DetailViewModel
    fileprivate let tableView: UITableView
    fileprivate let numberOfRows: Int = 1
    fileprivate let numberOfSections = Index.allCases.count
    
    fileprivate(set) var navigationCell: DetailNavigationTableViewCell?
    fileprivate(set) var collectionCell: DetailCollectionTableViewCell?
    
    /// Create a detail table view data source object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - viewModel: Coordinating view model.
    init(on tableView: UITableView, with viewModel: DetailViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        
        super.init()
        
        self.viewsDidRegister()
        self.dataSourceDidChange()
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        collectionCell?.removeFromSuperview()
        collectionCell = nil
        
        navigationCell?.removeFromSuperview()
        navigationCell = nil
    }
}

// MARK: - DataSourceProtocol Implementation

extension DetailTableViewDataSource: DataSourceProtocol {
    fileprivate func viewsDidRegister() {
        tableView.register(class: DetailInfoTableViewCell.self)
        tableView.register(class: DetailDescriptionTableViewCell.self)
        tableView.register(class: DetailPanelTableViewCell.self)
        tableView.register(class: DetailNavigationTableViewCell.self)
        tableView.register(class: DetailCollectionTableViewCell.self)
    }
    
    fileprivate func dataSourceDidChange() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func contentSize(with state: DetailNavigationView.State) -> Float {
        switch state {
        case .episodes:
            guard let season = viewModel.season.value as Season? else { return .zero }
            let cellHeight = Float(156.0)
            let lineSpacing = Float(8.0)
            let itemsCount = Float(season.episodes.count)
            let value = cellHeight * itemsCount + (lineSpacing * itemsCount)
            return Float(value)
        case .trailers:
            guard let trailers = viewModel.media?.resources.trailers as [String]? else { return .zero }
            let cellHeight = Float(224.0)
            let lineSpacing = Float(8.0)
            let itemsCount = Float(trailers.count)
            let value = cellHeight * itemsCount + (lineSpacing * itemsCount)
            return Float(value)
        default:
            let cellHeight = Float(146.0)
            let lineSpacing = Float(8.0)
            let itemsPerLine = Float(3.0)
            let topContentInset = Float(16.0)
            let itemsCount = Float(viewModel.section?.media.count ?? .zero)
            let roundedItemsOutput = (itemsCount / itemsPerLine).rounded(.awayFromZero)
            let value =
                roundedItemsOutput * cellHeight
                + lineSpacing * roundedItemsOutput
                + topContentInset
            return Float(value)
        }
    }
    
    fileprivate func reloadRow(at index: DetailTableViewDataSource.Index) {
        let indexPath = IndexPath(row: index.rawValue, section: .zero)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    fileprivate func heightForRow(at index: DetailTableViewDataSource.Index) {
        let indexPath = IndexPath(row: index.rawValue, section: .zero)
        tableView(tableView, heightForRowAt: indexPath)
    }
    
    func reloadData(at index: DetailTableViewDataSource.Index) {
        if case .collection = index {
            collectionCell?.detailCollectionView?.dataSourceDidChange()
        }
        
        heightForRow(at: index)
        reloadRow(at: index)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension DetailTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let index = Index(rawValue: indexPath.section) else { fatalError() }
        
        switch index {
        case .info:
            return DetailInfoTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .description:
            return DetailDescriptionTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .panel:
            return DetailPanelTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .navigation:
            navigationCell = DetailNavigationTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return navigationCell!
        case .collection:
            collectionCell = DetailCollectionTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return collectionCell!
        }
    }
    
    @discardableResult
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let view = viewModel.coordinator!.viewController!.view! as UIView?,
              let index = DetailTableViewDataSource.Index(rawValue: indexPath.section) else {
            return .zero
        }
        switch index {
        case .info: return view.bounds.height * 0.21
        case .description: return view.bounds.height * 0.135
        case .panel: return view.bounds.height * 0.0764
        case .navigation: return view.bounds.height * 0.0764
        case .collection:
            guard let viewModel = viewModel.coordinator?.viewController?.viewModel,
                  let ds = viewModel.coordinator?.viewController?.dataSource,
                  let state = ds.navigationCell?.navigationView?.viewModel.state.value
            else { return .zero }
            return CGFloat(contentSize(with: state))
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

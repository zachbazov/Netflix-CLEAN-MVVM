//
//  DetailTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit.UITableView

final class DetailTableViewDataSource: NSObject {
    private let viewModel: DetailViewModel
    private let tableView: UITableView
    private let numberOfRows: Int = 1
    private let numberOfSections = Index.allCases.count
    private var infoCell: DetailInfoTableViewCell!
    private var descriptionCell: DetailDescriptionTableViewCell!
    private var panelCell: DetailPanelTableViewCell!
    private var navigationCell: DetailNavigationTableViewCell!
    private(set) var collectionCell: DetailCollectionTableViewCell!
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
}

extension DetailTableViewDataSource {
    private func viewsDidRegister() {
        tableView.register(class: DetailInfoTableViewCell.self)
        tableView.register(class: DetailDescriptionTableViewCell.self)
        tableView.register(class: DetailPanelTableViewCell.self)
        tableView.register(class: DetailNavigationTableViewCell.self)
        tableView.register(class: DetailCollectionTableViewCell.self)
    }
    
    private func dataSourceDidChange() {
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
            guard let trailers = viewModel.media.resources.trailers as [String]? else { return .zero }
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
            let itemsCount = viewModel.homeDataSourceState == .series
                ? Float(viewModel.section.media.count)
                : Float(viewModel.section.media.count)
            let roundedItemsOutput = (itemsCount / itemsPerLine).rounded(.awayFromZero)
            let value =
                roundedItemsOutput * cellHeight
                + lineSpacing * roundedItemsOutput
                + topContentInset
            return Float(value)
        }
    }
}

extension DetailTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let index = Index(rawValue: indexPath.section) else { fatalError() }
        if case .info = index {
            guard infoCell == nil else { return infoCell }
            infoCell = DetailInfoTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return infoCell
        } else if case .description = index {
            guard descriptionCell == nil else { return descriptionCell }
            descriptionCell = DetailDescriptionTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return descriptionCell
        } else if case .panel = index {
            guard panelCell == nil else { return panelCell }
            panelCell = DetailPanelTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return panelCell
        } else if case .navigation = index {
            guard navigationCell == nil else { return navigationCell }
            navigationCell = DetailNavigationTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return navigationCell
        } else {
            guard collectionCell == nil else { return collectionCell }
            collectionCell = DetailCollectionTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return collectionCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let view = viewModel.coordinator!.viewController!.view! as UIView?,
              let dataSource = viewModel.coordinator!.viewController!.dataSource,
              let index = DetailTableViewDataSource.Index(rawValue: indexPath.section) else {
            return .zero
        }
        switch index {
        case .info: return view.bounds.height * 0.21
        case .description: return view.bounds.height * 0.135
        case .panel: return view.bounds.height * 0.0764
        case .navigation: return view.bounds.height * 0.0764
        case .collection:
            switch viewModel.navigationViewState.value {
            case .episodes, .trailers:
                return CGFloat(dataSource.contentSize(with: viewModel.navigationViewState.value))
            default:
                return CGFloat(dataSource.contentSize(with: viewModel.navigationViewState.value))
            }
        }
    }
}

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

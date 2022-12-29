//
//  NewsTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit.UITableView

// MARK: - NewsTableViewDataSource Type

final class NewsTableViewDataSource: NSObject {
    
    // MARK: Properties
    
    private let viewModel: NewsViewModel
    private let numberOfSections: Int = 1
    
    // MARK: Initializer
    
    /// Create a news table view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - UI Setup

extension NewsTableViewDataSource {
    func dataSourceDidChange() {
        guard let tableView = viewModel.coordinator!.viewController!.tableView else { return }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension NewsTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return NewsTableViewCell.create(in: tableView, for: indexPath, with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = indexPath.row as Int?, row >= 0, row <= viewModel.items.value.count - 1 else { return }
        let homeNavigation = Application.current.rootCoordinator.tabCoordinator.home!
        let newsNavigation = Application.current.rootCoordinator.tabCoordinator.news!
        let homeController = homeNavigation.viewControllers.first! as! HomeViewController
        let homeViewModel = homeController.viewModel
        let newsController = newsNavigation.viewControllers.first! as! NewsViewController
        let newsCoordinator = newsController.viewModel.coordinator!
        let cellViewModel = viewModel.items.value[row]
        let section = homeViewModel?.section(at: .resumable)
        newsCoordinator.section = section
        newsCoordinator.media = cellViewModel.media
        newsCoordinator.shouldScreenRotate = false
        newsCoordinator.showScreen(.detail)
    }
    
}

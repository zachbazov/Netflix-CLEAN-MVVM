//
//  NewsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - NewsViewController Type

final class NewsViewController: UIViewController {
    
    // MARK: Outlet Properties
    
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private(set) var tableViewContainer: UIView!
    
    // MARK: Type's Properties
    
    var viewModel: NewsViewModel!
    private var navigationView: NewsNavigationView!
    private(set) var tableView: UITableView!
    private var dataSource: NewsTableViewDataSource!
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupObservers()
        viewModel.viewDidLoad()
    }
}

// MARK: - UI Setup

extension NewsViewController {
    
    private func setupSubviews() {
        setupNavigationView()
        setupTableView()
        setupDataSource()
    }
    
    private func setupNavigationView() {
        navigationView = NewsNavigationView(on: navigationViewContainer)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: tableViewContainer.bounds, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(nib: NewsTableViewCell.self)
        tableView.backgroundColor = .black
        
        tableViewContainer.addSubview(tableView)
    }
    
    private func setupDataSource() {
        dataSource = NewsTableViewDataSource(with: viewModel)
    }
}

// MARK: - Observers

extension NewsViewController {
    private func setupObservers() {
        viewModel.items.observe(on: self) { [weak self] _ in
            guard let self = self, !self.viewModel.isEmpty else { return }
            self.dataSource.dataSourceDidChange()
        }
    }
    
    func removeObservers() {
        if let viewModel = viewModel {
            printIfDebug("Removed `NewsViewModel` observers.")
            viewModel.items.remove(observer: self)
        }
    }
}

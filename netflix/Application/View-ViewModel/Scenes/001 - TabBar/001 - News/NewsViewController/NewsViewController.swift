//
//  NewsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerOutput {
    var navigationView: NewsNavigationView! { get }
    var tableView: UITableView! { get }
    var dataSource: NewsTableViewDataSource! { get }
}

private typealias ControllerProtocol = ControllerOutput

// MARK: - NewsViewController Type

final class NewsViewController: Controller<NewsViewModel> {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private(set) var tableViewContainer: UIView!
    
    fileprivate var navigationView: NewsNavigationView!
    fileprivate(set) var tableView: UITableView!
    fileprivate var dataSource: NewsTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidBindObservers()
        viewModel.viewDidLoad()
    }
    
    override func viewDidDeploySubviews() {
        setupNavigationView()
        setupTableView()
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

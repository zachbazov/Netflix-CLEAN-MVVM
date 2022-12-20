//
//  NewsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

final class NewsViewController: UIViewController {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private(set) var tableViewContainer: UIView!
    
    var viewModel: NewsViewModel!
    private var navigationView: NewsNavigationView!
    private var tableView: UITableView!
    private var dataSource: NewsTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupObservers()
        viewModel.viewDidLoad()
    }
    
    private func setupSubviews() {
        setupNavigationView()
        setupTableView()
        setupDataSource()
    }
    
    private func setupObservers() {
        viewModel.items.observe(on: self) { [weak self] _ in
            guard !self!.viewModel.isEmpty else { return }
            self?.dataSourceDidChange()
        }
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
    
    private func dataSourceDidChange() {
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
}

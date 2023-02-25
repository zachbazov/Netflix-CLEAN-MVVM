//
//  HomeTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceOutput {
    var tableView: UITableView! { get }
    var viewModel: HomeViewModel! { get }
    var numberOfRows: Int { get }
    var showcaseCell: ShowcaseTableViewCell! { get }
    
    func viewDidLoad()
    func viewsDidRegister()
    func dataSourceDidChange()
}

private typealias DataSourceProtocol = DataSourceOutput

// MARK: - HomeTableViewDataSource Type

final class HomeTableViewDataSource: NSObject {
    fileprivate weak var tableView: UITableView!
    fileprivate weak var viewModel: HomeViewModel!
    fileprivate let numberOfRows = 1
    fileprivate(set) var showcaseCell: ShowcaseTableViewCell!
    /// Create an home's table view data source object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - viewModel: Coordinating view model.
    init(tableView: UITableView, viewModel: HomeViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        super.init()
        self.viewDidLoad()
    }
}

// MARK: - DataSourceProtocol Implementation

extension HomeTableViewDataSource: DataSourceProtocol {
    fileprivate func viewDidLoad() {
        viewsDidRegister()
        dataSourceDidChange()
    }
    
    fileprivate func viewsDidRegister() {
        tableView.register(headerFooter: TableViewHeaderFooterView.self)
        tableView.register(class: ShowcaseTableViewCell.self)
        tableView.register(class: RatedTableViewCell.self)
        tableView.register(class: ResumableTableViewCell.self)
        tableView.register(class: StandardTableViewCell.self)
    }
    
    func dataSourceDidChange() {
        // Filters the sections based on the data source state.
        viewModel.filter(sections: viewModel.sections)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension HomeTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let index = Index(rawValue: indexPath.section) else { fatalError() }
        switch index {
        case .display:
            showcaseCell = ShowcaseTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
            return showcaseCell
        case .rated:
            return RatedTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .resumable:
            return ResumableTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        default:
            return StandardTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let index = HomeTableViewDataSource.Index(rawValue: indexPath.section),
              let view = viewModel.coordinator?.viewController?.view else {
            return .zero
        }
        switch index {
        case .display: return view.bounds.height * 0.76
        default: return view.bounds.height * 0.19
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewHeaderFooterView.create(on: tableView, for: section, with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let index = Index(rawValue: section) else { return .zero }
        switch index {
        case .display: return 0.0
        case .rated: return 28.0
        default: return 24.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.opacityAnimation()
    }
}

// MARK: - UIScrollViewDelegate via UITableView Implementation

extension HomeTableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationViewAnimation(with: scrollView)
    }
}

// MARK: - Index Type

extension HomeTableViewDataSource {
    /// Section index representation type.
    enum Index: Int, CaseIterable {
        case display
        case rated
        case resumable
        case action
        case sciFi
        case blockbuster
        case myList
        case crime
        case thriller
        case adventure
        case comedy
        case drama
        case horror
        case anime
        case familyNchildren
        case documentary
    }
}

// MARK: - State Type

extension HomeTableViewDataSource {
    /// Section state representation type.
    enum State: Int, CaseIterable {
        case all
        case tvShows
        case movies
    }
}

// MARK: - Valuable Implementation

extension HomeTableViewDataSource.Index: Valuable {
    var stringValue: String {
        switch self {
        case .display, .rated, .resumable: return ""
        case .action: return "Action"
        case .sciFi: return "Sci-Fi"
        case .blockbuster: return "Blockbusters"
        case .myList: return "My List"
        case .crime: return "Crime"
        case .thriller: return "Thriller"
        case .adventure: return "Adventure"
        case .comedy: return "Comedy"
        case .drama: return "Drama"
        case .horror: return "Horror"
        case .anime: return "Anime"
        case .familyNchildren: return "Family & Children"
        case .documentary: return "Documentary"
        }
    }
}

// MARK: - Private UI Implementation

extension HomeTableViewDataSource {
    private func navigationViewAnimation(with scrollView: UIScrollView) {
        guard let homeViewController = viewModel.coordinator?.viewController,
              let translation = scrollView.panGestureRecognizer.translation(in: homeViewController.view) as CGPoint? else {
            return
        }
        let isScrollingUp = translation.y < 0
        let targetConstant: CGFloat = isScrollingUp
            ? -homeViewController.navigationView.bounds.size.height
            : 0.0
        let targetAlpha: CGFloat = isScrollingUp ? 0.0 : 1.0
        
        let animator = UIViewPropertyAnimator(duration: 0.66, dampingRatio: 1.0) {
            homeViewController.navigationViewTopConstraint.constant = targetConstant
            homeViewController.navigationView.alpha = targetAlpha
            homeViewController.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

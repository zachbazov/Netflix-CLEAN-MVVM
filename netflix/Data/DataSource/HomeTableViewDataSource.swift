//
//  HomeTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

final class HomeTableViewDataSource: NSObject {
    weak var tableView: UITableView!
    private weak var viewModel: HomeViewModel!
    
    fileprivate let numberOfRows = 1
    var displayCell: DisplayTableViewCell!
    
    init(tableView: UITableView, viewModel: HomeViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        super.init()
        self.viewDidLoad()
    }
    
    fileprivate func viewDidLoad() {
        viewsDidRegister()
        dataSourceDidChange()
    }
    
    fileprivate func viewsDidRegister() {
        tableView.register(headerFooter: TableViewHeaderFooterView.self)
        tableView.register(nib: DisplayTableViewCell.self)
        tableView.register(class: RatedTableViewCell.self)
        tableView.register(class: ResumableTableViewCell.self)
        tableView.register(class: StandardTableViewCell.self)
    }
    
    func dataSourceDidChange() {
        /// Filters the sections based on the data source state.
        viewModel.filter(sections: viewModel.sections)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func terminate() {
        tableView.removeFromSuperview()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView = nil
    }
}

extension HomeTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let index = Index(rawValue: indexPath.section) else { fatalError() }
        
        if case .display = index {
            guard displayCell == nil else { return displayCell }
            displayCell = DisplayTableViewCell(for: indexPath, with: viewModel)
            return displayCell
        } else if case .rated = index {
            return RatedTableViewCell(for: indexPath, with: viewModel)
        } else if case .resumable = index {
            return ResumableTableViewCell(for: indexPath, with: viewModel)
        } else {
            return StandardTableViewCell(for: indexPath, with: viewModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let view = viewModel.coordinator!.viewController!.view!
        if case .display = HomeTableViewDataSource.Index(rawValue: indexPath.section) {
            return view.bounds.height * 0.76
        }
        return view.bounds.height * 0.19
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewHeaderFooterView(for: section, with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let index = Index(rawValue: section) else { return .zero }
        if case .display = index { return 0.0 }
        else if case .rated = index { return 28.0 }
        else { return 24.0 }
    }
}

extension HomeTableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let homeViewController = viewModel.coordinator?.viewController,
              let translation = scrollView.panGestureRecognizer.translation(in: homeViewController.view) as CGPoint? else {
            return
        }
        homeViewController.view.animateUsingSpring(withDuration: 0.66,
                                                   withDamping: 1.0,
                                                   initialSpringVelocity: 1.0) {
            guard translation.y < 0 else {
                homeViewController.navigationViewTopConstraint.constant = 0.0
                homeViewController.navigationView.alpha = 1.0
                return homeViewController.view.layoutIfNeeded()
            }
            homeViewController.navigationViewTopConstraint.constant = -homeViewController.navigationView.bounds.size.height
            homeViewController.navigationView.alpha = 0.0
            homeViewController.view.layoutIfNeeded()
        }
    }
}

extension HomeTableViewDataSource {
    /// Section's index representation type.
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
    /// Data source's state representation type.
    enum State: Int, CaseIterable {
        case all
        case series
        case films
    }
}

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

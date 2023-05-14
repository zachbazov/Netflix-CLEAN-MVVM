//
//  HomeTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var tableView: UITableView? { get }
    var viewModel: HomeViewModel { get }
    var numberOfRows: Int { get }
    var initialOffsetY: CGFloat { get }
    var primaryOffsetY: CGFloat { get }
    
    func didLoad()
    func cellsWillRegister()
    func dataSourceWillChange()
    func contentWillInset()
    func applyStyleChanges(_ condition: Bool, limit: CGFloat)
}

// MARK: - HomeTableViewDataSource Type

final class HomeTableViewDataSource: NSObject {
    fileprivate weak var tableView: UITableView?
    fileprivate let viewModel: HomeViewModel
    
    fileprivate let numberOfRows: Int = 1
    fileprivate var initialOffsetY: CGFloat = .zero
    fileprivate(set) var primaryOffsetY: CGFloat = .zero
    
    /// Create an home's table view data source object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - viewModel: Coordinating view model.
    init(tableView: UITableView, viewModel: HomeViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        
        super.init()
        
        self.didLoad()
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        tableView?.removeFromSuperview()
        tableView = nil
        
        viewModel.coordinator = nil
    }
}

// MARK: - DataSourceProtocol Implementation

extension HomeTableViewDataSource: DataSourceProtocol {
    fileprivate func didLoad() {
        cellsWillRegister()
        contentWillInset()
    }
    
    fileprivate func cellsWillRegister() {
        tableView?.register(headerFooter: TableViewHeaderFooterView.self)
        tableView?.register(class: ShowcaseTableViewCell.self)
        tableView?.register(class: RatedTableViewCell.self)
        tableView?.register(class: ResumableTableViewCell.self)
        tableView?.register(class: StandardTableViewCell.self)
        tableView?.register(class: BlockbusterTableViewCell.self)
    }
    
    func dataSourceWillChange() {
        viewModel.sectionsWillFilter()
        
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.reloadData()
    }
    
    fileprivate func contentWillInset() {
        guard let controller = viewModel.coordinator?.viewController,
              let window = UIApplication.shared.windows.first
        else { return }
        
        let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.size.height ?? .zero
        let remainder = controller.view.bounds.height - controller.navigationViewContainer.bounds.height
        let offset = controller.view.bounds.height - remainder - statusBarHeight
        
        initialOffsetY = offset
        
        tableView?.contentInset = .init(top: initialOffsetY, left: .zero, bottom: .zero, right: .zero)
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
            return ShowcaseTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .rated:
            return RatedTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .resumable:
            return ResumableTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        case .blockbuster:
            return BlockbusterTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        default:
            return StandardTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let index = HomeTableViewDataSource.Index(rawValue: indexPath.section),
              let view = viewModel.coordinator?.viewController?.view
        else { return .zero }
        
        switch index {
        case .display: return view.bounds.height * 0.710 - 96.0
        case .blockbuster: return view.bounds.height * 0.375
        default: return view.bounds.height * 0.190
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let index = Index(rawValue: section) else { return nil }
        
        switch index {
        default:
            return TableViewHeaderFooterView.create(on: tableView, for: section, with: viewModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let index = Index(rawValue: section) else { return .zero }
        switch index {
        case .display: return .zero
        case .newRelease: return 32.0
        default: return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let window = UIApplication.shared.windows.first,
              let controller = viewModel.coordinator?.viewController
        else { return }
        
        let offsetY = scrollView.panGestureRecognizer.translation(in: controller.view).y
        let isScrollingUp = offsetY > .zero
        
        let segmentY = -scrollView.contentOffset.y - controller.navigationViewContainer.bounds.height
        var segmentMaxY = max(.zero, -segmentY)
        primaryOffsetY = min(.zero, -scrollView.contentOffset.y - controller.navigationViewContainer.bounds.height)
        
        let segmentHeight = controller.navigationView?.segmentControl?.bounds.size.height ?? .zero
        let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero
        let heightLimit: CGFloat = statusBarHeight + initialOffsetY
        
        primaryOffsetY = -primaryOffsetY
        
        segmentMaxY = segmentMaxY > segmentHeight ? segmentHeight : segmentMaxY
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                
                if isScrollingUp {
                    let condition = self.primaryOffsetY <= segmentHeight
                    
                    controller.navigationViewContainerHeight.constant = condition
                        ? heightLimit + (-segmentMaxY * 2)
                        : heightLimit
                    
                    controller.navigationView?.segmentControl?.origin(
                        y: condition
                            ? -segmentMaxY
                            : -segmentMaxY + segmentHeight)
                    
                    controller.navigationView?.segmentControl?.alpha = condition
                        ? 1.0 - (segmentMaxY / segmentHeight)
                        : 1.0
                } else {
                    controller.navigationViewContainerHeight.constant = heightLimit + -segmentMaxY
                    controller.navigationView?.segmentControl?.origin(y: -segmentMaxY)
                    controller.navigationView?.segmentControl?.alpha = 1.0 - (segmentMaxY / segmentHeight)
                }
                
                self.applyStyleChanges(isScrollingUp, limit: segmentHeight)
            })
    }
    
    fileprivate func applyStyleChanges(_ condition: Bool, limit: CGFloat) {
        guard let controller = viewModel.coordinator?.viewController else { return }
        
        if condition {
            if self.primaryOffsetY <= limit {
                controller.navigationView?.apply(.gradient)
            } else {
                controller.navigationView?.apply(.blur)
            }
            
            if self.primaryOffsetY <= .zero {
                controller.navigationView?.apply(.gradient)
            }
        } else {
            guard self.primaryOffsetY >= .zero else {
                controller.navigationView?.apply(.gradient)
                
                return
            }
            
            controller.navigationView?.apply(.blur)
        }
    }
}

// MARK: - Index Type

extension HomeTableViewDataSource {
    /// Section index representation type.
    enum Index: Int, CaseIterable {
        case display
        case newRelease
        case resumable
        case action
        case rated
        case sciFi
        case myList
        case blockbuster
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
        case .display: return "Display"
        case .rated: return "Top Rated"
        case .resumable: return "Resume Watching"
        case .newRelease: return "New Release"
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

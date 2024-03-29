//
//  MediaTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: HomeViewModel { get }
    var showcaseCell: ShowcaseTableViewCell? { get }
    
    var initialOffsetY: CGFloat { get }
    var primaryOffsetY: CGFloat { get }
    
    func setContentInset()
}

// MARK: - MediaTableViewDataSource Type

final class MediaTableViewDataSource: TableViewDataSource {
    fileprivate let viewModel: HomeViewModel
    
    var showcaseCell: ShowcaseTableViewCell?
    
    fileprivate(set) var initialOffsetY: CGFloat = .zero
    fileprivate(set) var primaryOffsetY: CGFloat = .zero
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.setContentInset()
    }
    
    deinit {
        showcaseCell?.viewWillDeallocate()
        showcaseCell = nil
    }
    
    // MARK: TableViewDataSourceProtocol Implementation
    
    override func numberOfSections() -> Int {
        return viewModel.sections.count
    }
    
    override func numberOfRows(in section: Int) -> Int {
        return 1
    }
    
    override func cellForRow<T>(in tableView: UITableView, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let index = Index(rawValue: indexPath.section) else { fatalError() }
        
        switch index {
        case .display:
            showcaseCell = ShowcaseTableViewCell.create(of: ShowcaseTableViewCell.self,
                                                        on: tableView,
                                                        for: indexPath,
                                                        with: viewModel)
            return showcaseCell as! T
        case .rated:
            return MediaHybridCell.create(expecting: MediaHybridCell<RatedCollectionViewCell>.self,
                                          embedding: RatedCollectionViewCell.self,
                                          on: tableView,
                                          for: indexPath,
                                          with: viewModel) as! T
        case .resumable:
            return MediaHybridCell.create(expecting: MediaHybridCell<ResumableCollectionViewCell>.self,
                                          embedding: ResumableCollectionViewCell.self,
                                          on: tableView,
                                          for: indexPath,
                                          with: viewModel) as! T
        case .blockbuster:
            return MediaHybridCell.create(expecting: MediaHybridCell<BlockbusterCollectionViewCell>.self,
                                          embedding: BlockbusterCollectionViewCell.self,
                                          on: tableView,
                                          for: indexPath,
                                          with: viewModel) as! T
        default:
            return MediaHybridCell.create(expecting: MediaHybridCell<StandardCollectionViewCell>.self,
                                          embedding: StandardCollectionViewCell.self,
                                          on: tableView,
                                          for: indexPath,
                                          with: viewModel) as! T
        }
    }
    
    override func heightForRow(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        guard let index = MediaTableViewDataSource.Index(rawValue: indexPath.section),
              let view = viewModel.coordinator?.viewController?.view
        else { return .zero }
        
        switch index {
        case .display: return view.bounds.height * 0.710 - 96.0
        case .blockbuster: return view.bounds.height * 0.375
        default: return view.bounds.height * 0.190
        }
    }
    
    override func willDisplayCellForRow(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    override func viewForHeader(in tableView: UITableView, at section: Int) -> UIView? {
        guard let index = Index(rawValue: section) else { return nil }
        
        switch index {
        default:
            return LabeledTableHeaderView.create(of: LabeledTableHeaderView.self,
                                                 on: tableView,
                                                 for: section,
                                                 with: viewModel)
        }
    }
    
    override func heightForHeader(in section: Int) -> CGFloat {
        guard let index = Index(rawValue: section) else { return .zero }
        
        switch index {
        case .display: return .zero
        case .newRelease: return 32.0
        default: return 44.0
        }
    }
    
    override func tableViewDidScroll(_ scrollView: UIScrollView) {
        guard let controller = viewModel.coordinator?.viewController else { return }
        
        let offsetY: CGFloat = scrollView.panGestureRecognizer.translation(in: controller.view).y
        let contentOffsetY = scrollView.contentOffset.y
        let adjustedOffset = max(min(offsetY, 0), -48.0)
        
        let segmentHeight: CGFloat = 48.0
        let navigationContainerHeight: CGFloat = 160.0
        
        let segmentY = -contentOffsetY - navigationContainerHeight
        var segmentMaxY = max(.zero, -segmentY)
        
        let isScrollingUp = offsetY > .zero
        
        primaryOffsetY = min(.zero, segmentY)
        primaryOffsetY = -primaryOffsetY
        
        segmentMaxY = segmentMaxY > segmentHeight ? segmentHeight : segmentMaxY
        
        applyStyleChanges(isScrollingUp, y: segmentY)
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseInOut,
            animations: {
                self.applyNavigationAdjustments(isScrollingUp, y: adjustedOffset)
            })
    }
}

// MARK: - DataSourceProtocol Implementation

extension MediaTableViewDataSource: DataSourceProtocol {
    func dataSourceWillChange() {
        guard let controller = viewModel.coordinator?.viewController,
              let tableView = controller.tableView
        else { return }
        
        viewModel.sectionsWillFilter()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func setContentInset() {
        guard let controller = viewModel.coordinator?.viewController,
              let tableView = controller.tableView,
              let window = UIApplication.shared.windows.first
        else { return }

        let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.size.height ?? .zero
        let offset = controller.navigationViewContainer.bounds.height - statusBarHeight
        
        initialOffsetY = offset
        
        tableView.contentInset = .init(top: initialOffsetY, left: .zero, bottom: .zero, right: .zero)
    }
}

// MARK: - Index Type

extension MediaTableViewDataSource {
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

extension MediaTableViewDataSource {
    /// Section state representation type.
    enum State: Int, CaseIterable {
        case all
        case tvShows
        case movies
    }
}

// MARK: - Valuable Implementation

extension MediaTableViewDataSource.Index: Valuable {
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

// MARK: - Private Implementation

extension MediaTableViewDataSource {
    func applyStyleChanges(_ condition: Bool, y: CGFloat) {
        guard let controller = viewModel.coordinator?.viewController else { return }
        
        if condition {
            if -y <= .zero {
                controller.navigationView?.apply(.gradient)
            } else {
                controller.navigationView?.apply(.blur)
            }
        } else {
            if -y >= 48.0 {
                controller.navigationView?.apply(.blur)
            }
        }
    }
    
    func applyNavigationAdjustments(_ condition: Bool, y: CGFloat) {
        guard let controller = viewModel.coordinator?.viewController else { return }
        
        controller.navigationView?.segmentControl?.origin(y: y)
        
        if condition {
            controller.navigationViewContainerHeight.constant = 160.0
            controller.navigationView?.segmentControl?.alpha = 1.0
        } else {
            controller.navigationViewContainerHeight.constant = 160.0 - 48.0
            controller.navigationView?.segmentControl?.alpha = .zero
        }
    }
}

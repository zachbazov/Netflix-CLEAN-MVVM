//
//  HomeTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var tableView: UITableView! { get }
    var viewModel: HomeViewModel! { get }
    var numberOfRows: Int { get }
    var showcaseCell: ShowcaseTableViewCell! { get }
    
    func viewDidLoad()
    func viewsDidRegister()
    func dataSourceDidChange()
    func insetContent()
}

// MARK: - HomeTableViewDataSource Type

final class HomeTableViewDataSource: NSObject {
    fileprivate weak var tableView: UITableView!
    fileprivate weak var viewModel: HomeViewModel!
    fileprivate let numberOfRows = 1
    fileprivate(set) var showcaseCell: ShowcaseTableViewCell!
    
    
    let blurEffect = UIBlurEffect(style: .dark)
    var blurView: UIVisualEffectView?
    
    var colors = [UIColor]()
    
    var gradientView: UIView!
    let gradientLayer = CAGradientLayer()
    
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
    
    deinit {
        print("deinit \(Self.self)")
        showcaseCell.removeFromSuperview()
        showcaseCell = nil
        tableView.removeFromSuperview()
        tableView = nil
        viewModel.coordinator = nil
        viewModel = nil
    }
}

// MARK: - DataSourceProtocol Implementation

extension HomeTableViewDataSource: DataSourceProtocol {
    fileprivate func viewDidLoad() {
        viewsDidRegister()
        insetContent()
    }
    
    fileprivate func viewsDidRegister() {
        tableView.register(headerFooter: TableViewHeaderFooterView.self)
        tableView.register(class: ShowcaseTableViewCell.self)
        tableView.register(class: RatedTableViewCell.self)
        tableView.register(class: ResumableTableViewCell.self)
        tableView.register(class: StandardTableViewCell.self)
        tableView.register(class: BlockbusterTableViewCell.self)
    }
    
    func dataSourceDidChange() {
        viewModel?.filter(sections: viewModel?.sections ?? [])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    fileprivate func insetContent() {
        guard let viewController = viewModel.coordinator?.viewController else { return }
        tableView.contentInset = .init(top: viewController.topContainer.bounds.size.height, left: .zero, bottom: .zero, right: .zero)
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
        case .blockbuster:
            return BlockbusterTableViewCell.create(on: tableView, for: indexPath, with: viewModel)
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
        guard let viewController = viewModel.coordinator?.viewController else { return }
        
        let topContainerHeight = viewController.topContainer.bounds.size.height
        let segmentContainerHeight = viewController.segmentViewContainer.bounds.size.height
        let currentOffsetY = scrollView.contentOffset.y
        
        let segmentY = min(0, -currentOffsetY - topContainerHeight - segmentContainerHeight)
        var maxSegmentY = max(0.0, -segmentY)
        maxSegmentY = maxSegmentY > 48.0 ? 48.0 : maxSegmentY
        
        print(currentOffsetY, segmentY)
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseOut,
            animations: { [weak self] in
                guard let self = self else { return }
                
                viewController.segmentControlView?.frame = CGRect(x: 0, y: segmentY, width: scrollView.bounds.width, height: 48.0)
                viewController.segmentControlView?.alpha = maxSegmentY > 1 ? .zero : 1.0
                viewController.topContainerHeight?.constant = -maxSegmentY + 96.0
                
                if maxSegmentY > .zero {
                    self.gradientView.isNotNil
                        ? _ = (self.gradientView?.removeFromSuperview(),
                               self.gradientView = nil)
                        : nil
                    self.blurView.isNil
                        ? _ = (viewController.blurryContainer.backgroundColor = .clear,
                               self.blurView = UIVisualEffectView(effect: self.blurEffect),
                               viewController.blurryContainer.insertSubview(self.blurView!, at: 0),
                               self.blurView!.constraintToSuperview(viewController.blurryContainer))
                        : nil
                } else {
                    self.gradientView.isNil
                        ? viewController.dataSource?.setupGradient(with: viewController)
                        : nil
                    self.blurView.isNotNil
                        ? _ = (self.blurView?.removeFromSuperview(),
                               self.blurView = nil)
                        : nil
                }
            })
    }
    
    func setupGradient(with controller: HomeViewController) {
        guard !colors.isEmpty else { return }
        
        gradientView = UIView(frame: controller.blurryContainer.bounds)
        
        let color1 = colors[0]
        let color2 = colors[1]
        let color3 = colors[2]
        
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.black.cgColor,
                                color3.cgColor,
                                color2.cgColor,
                                color1.cgColor]
        gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        
        controller.blurryContainer.insertSubview(gradientView, at: 0)
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
        case .display, .rated, .resumable: return ""
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



/*
 print(offsetY, scrollView.contentOffset.y)
 //        let isScrollingUp = offsetY > 0
 ////        let isScrollingDown = offsetY <= 0 || offsetY < -55.0
 //        let segmentControlAlpha: CGFloat = isScrollingUp ? 1.0 : .zero
 //        let segmentContainerHeight: CGFloat = isScrollingUp ? 48.0 : .zero
 //        let topContainerHeight: CGFloat = isScrollingUp ? 96.0 : 48.0
 //        let blurryContainerHeight: CGFloat = isScrollingUp ? 202.0 : 154.0
 //
 //        gradientView?.backgroundColor = .clear
 //
 ////        viewController.segmentControlView?.alpha = segmentControlAlpha
 ////        viewController.segmentContainerHeight.constant = segmentContainerHeight
 //
 //        gradientView?.frame = CGRect(x: .zero,
 //                                     y: .zero,
 //                                     width: viewController.topContainer.bounds.width,
 //                                     height: topContainerHeight)
 //
 //        if offsetY > .zero {
 //            print(scrollView.contentOffset.y <= -151.0)
 //            if scrollView.contentOffset.y <= -151.0 {
 //
 //                viewController.topContainerHeight.constant = -(scrollView.contentOffset.y)
 ////                viewController.blurryContainerHeight.constant = -scrollView.contentOffset.y
 //
 //                if gradientView == nil {
 //                    viewController.dataSource?.setupGradient(with: viewController)
 //                }
 //
 //                blurView?.removeFromSuperview()
 //                blurView = nil
 //            }
 //        } else {
 ////            viewController.topContainerHeight.constant = scrollView.contentOffset.y
 ////            viewController.blurryContainerHeight.constant = scrollView.contentOffset.y
 //
 //            gradientView?.removeFromSuperview()
 //            gradientView = nil
 //
 //            if blurView == nil {
 //                viewController.blurryContainer.backgroundColor = .clear
 //                blurView = UIVisualEffectView(effect: blurEffect)
 //                viewController.blurryContainer.insertSubview(blurView!, at: 0)
 //                blurView!.constraintToSuperview(viewController.blurryContainer)
 //            }
 //        }
 */

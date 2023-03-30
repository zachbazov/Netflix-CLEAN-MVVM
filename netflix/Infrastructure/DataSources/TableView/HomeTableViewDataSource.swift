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
    
    var initialOffsetY: CGFloat = .zero
    
    var isSegmentedShrunk = false
    var isAnimating = false
    
    lazy var topContainerHeight: CGFloat = {
        guard let viewController = viewModel.coordinator?.viewController else { return .zero }
        return viewController.topContainer.bounds.size.height
    }()
    lazy var segmentContainerHeight: CGFloat = {
        guard let viewController = viewModel.coordinator?.viewController else { return .zero }
        return viewController.segmentViewContainer.bounds.size.height
    }()
    
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
        let inset = viewController.topContainer.bounds.size.height
        tableView.contentInset = .init(top: inset, left: .zero, bottom: .zero, right: .zero)
        initialOffsetY = inset
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
        guard let viewController = viewModel.coordinator?.viewController,
              let view = viewController.view,
              let offsetY = scrollView.panGestureRecognizer.translation(in: view).y as CGFloat?
        else { return }
        
        let isScrollingUp = offsetY > .zero
        let topContainerHeight = viewController.topContainer.bounds.size.height
        let segmentContainerHeight = viewController.segmentViewContainer.bounds.size.height
        let currentOffsetY = scrollView.contentOffset.y
        
        let segmentY = min(0, -currentOffsetY - topContainerHeight - segmentContainerHeight)
        var segmentMaxY = max(0.0, -segmentY)
        segmentMaxY = segmentMaxY > 48.0 ? 48.0 : segmentMaxY
        let statusBarHeight: CGFloat = 59.0
        let requiredHeight: CGFloat = statusBarHeight + initialOffsetY
        
        printIfDebug(.debug, "CURRENT OFFSET Y: \(currentOffsetY)")
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .allowAnimatedContent,
            animations: { [weak self] in
                guard let self = self else { return }
                if isScrollingUp {
                    if currentOffsetY < requiredHeight {
                        //up
                        // hide 1
                        print("currentOffsetY < requiredHeight")
                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                        viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
                        
                    } else if currentOffsetY == requiredHeight {
                        //up
                        print("currentOffsetY == requiredHeight")
                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY + 48.0, width: scrollView.bounds.width, height: 48.0)
                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0 + 48.0
                        viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
                        
                    } else {
                        //down
                        print("else up")
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
                    }
                    if currentOffsetY > requiredHeight {
                        // down
                        print("currentOffsetY > requiredHeight")
                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY + 48.0, width: scrollView.bounds.width, height: 48.0)
                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0 + 48.0
                        viewController.segmentControlView?.alpha = 1
                    } else {
                        //up
                        print("else up2")
                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                        //                        viewController.segmentControlView?.alpha = 0
                        
                        if -currentOffsetY >= requiredHeight {
                            print("equals")
                            self.gradientView.isNil
                            ? viewController.dataSource?.setupGradient(with: viewController)
                            : nil
                            self.blurView.isNotNil
                            ? _ = (self.blurView?.removeFromSuperview(),
                                   self.blurView = nil)
                            : nil
                        }
                    }
                    
                } else {
                    if currentOffsetY > requiredHeight {
                        print("down close")
                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                        viewController.segmentControlView?.alpha = -segmentMaxY > 1 ? 1.0 : .zero
                    } else {
                        print("down else")
                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                        viewController.segmentControlView?.alpha = -segmentMaxY > 1 ? 1.0 : .zero
                    }
                    
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
                }
            })
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let viewController = viewModel.coordinator?.viewController,
//              let view = viewController.view,
//              let offsetY = scrollView.panGestureRecognizer.translation(in: view).y as CGFloat?
//        else { return }
//
//        let currentOffsetY = scrollView.contentOffset.y
//
//        let segmentY = min(0, -currentOffsetY - topContainerHeight - segmentContainerHeight)
//        var segmentMaxY = max(0.0, -segmentY)
//        segmentMaxY = segmentMaxY > 48.0 ? 48.0 : segmentMaxY
//
//        let isScrollingUp = offsetY > .zero
//
//        let scrollingDownIsSmallerThanPassed48 = !isScrollingUp && -segmentY < 48.0
//        let scrollingDownIsLargerThan48AndInRange = !isScrollingUp && -segmentY >= 48.0 && -segmentY < scrollView.contentSize.height
//
//        let scrollingUpHasPassed48 = isScrollingUp && -segmentY <= 48.0
//
//        let statusBarHeight: CGFloat = 59.0
//        let requiredHeight: CGFloat = -(statusBarHeight + initialOffsetY)
//
//        let reqNegativeShow: CGFloat = requiredHeight + 48.0
//
//        printIfDebug(.none, "CURRENT OFFSET Y: \(currentOffsetY) , \(-segmentY) , \(segmentMaxY)")
////        printIfDebug(.debug, "SEGMENT Y: \(segmentY)")
////        printIfDebug(.debug, "MAX SEGMENT Y: \(segmentMaxY)")
////        printIfDebug(.debug, "TOP CONTAINER HEIGHT: \(-segmentMaxY + 96.0)")
//
//
//
//        let yOffset = scrollView.contentOffset.y
//
//            // Define the maximum and minimum values for the y offset that trigger the resizing
//        let maxOffset: CGFloat = scrollView.contentSize.height // adjust as needed
//        let minOffset: CGFloat = 48.0 // adjust as needed
//
//        if !isAnimating {
//            UIView.animate(withDuration: 0.3) {
//
//                if isScrollingUp {
//                    // up (close)
//                    viewController.segmentControlView?.frame = CGRect(x: .zero, y: -segmentMaxY - 48.0, width: scrollView.bounds.width, height: 48.0)
//                    viewController.segmentControlView?.alpha = -segmentMaxY / 48.0
//                    viewController.blurryContainer?.frame = CGRect(x: .zero, y: -segmentMaxY - 48.0, width: scrollView.bounds.width, height: 202.0)
//                } else {
//                    // down (open)
//                    viewController.segmentControlView?.frame = CGRect(x: .zero, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
//                    viewController.segmentControlView?.alpha = -segmentMaxY / 48.0
//                    viewController.blurryContainer?.frame = CGRect(x: .zero, y: -segmentMaxY, width: scrollView.bounds.width, height: 202.0)
//                }
//
////                if currentOffsetY < .zero && currentOffsetY <= -1.0 && currentOffsetY < reqNegativeShow {
////
////
////                }
////                print("x", self.initialOffsetY + reqNegativeShow)
////                if currentOffsetY < .zero && currentOffsetY <= -1.0 && currentOffsetY > self.initialOffsetY + reqNegativeShow {
////                    print("show")
////                    // show the segment control view
////                    viewController.segmentControlView?.frame.origin.y = -segmentMaxY
////
////                    // show the blurry container
////                    viewController.segmentControlView?.alpha = 1.0
////                    viewController.blurryContainer?.frame.origin.y = 0
////                }
//            } completion: { [weak self] _ in
//                    self?.isAnimating = false
//            }
//
//            isAnimating = true
//        }
//
//
//
//
////                viewController.segmentControlView?.frame = CGRect(
////                    x: viewController.segmentControlView!.frame.origin.x,
////                    y: -segmentMaxY,
////                    width: viewController.segmentControlView!.frame.width,
////                    height: viewController.segmentControlView!.frame.height
////                )
//
////                viewController.segmentControlView?.frame = CGRect(x: 0, y: isScrollingUp ? -segmentMaxY : -segmentMaxY, width: scrollView.bounds.width, height: isScrollingUp ? 48.0 + -segmentMaxY : 48.0 + segmentMaxY)
////                viewController.blurryContainer?.frame = CGRect(x: 0, y: isScrollingUp ? -segmentMaxY : -segmentMaxY, width: scrollView.bounds.width, height: isScrollingUp ? 155.0 + -segmentMaxY : 155.0 + segmentMaxY)
////                viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
//
////                if scrollingDownIsSmallerThanPassed48 {
////                    print("smallerThan48", currentOffsetY, -segmentY)
////                    viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
////                    viewController.blurryContainer?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 155.0)
////                    viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                }
////
////                if scrollingDownIsLargerThan48AndInRange {
////                    print("LargerThan48AndInRange", currentOffsetY, -segmentY)
////                    viewController.segmentControlView?.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: 48.0 + -segmentMaxY)
////                    viewController.blurryContainer?.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: 155.0 + -segmentMaxY)
////                    viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                }
//////
////                if scrollingUpHasPassed48 {
////                    print("up", currentOffsetY, -segmentY)
////                    viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
////                    viewController.blurryContainer?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 155.0)
////                    viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                }
//
//
////                if isScrollingUp {
////                    if currentOffsetY < requiredHeight {
////                        guard -segmentMaxY <= 48.0 else { return }
//////                        print("UP currentOffsetY < requiredHeight", currentOffsetY < requiredHeight, -segmentMaxY)
//////                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
//////                        viewController.blurryContainer?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 155.0)
//////                        viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                    } else if currentOffsetY > requiredHeight {
////                        guard -segmentMaxY >= 48.0 else { return }
//////                        print("UP currentOffsetY > requiredHeight", currentOffsetY > requiredHeight)
//////                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
//////                        viewController.blurryContainer?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 155.0)
//////                        viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                    }
////                } else {
////                    if currentOffsetY > requiredHeight {
////                        guard -segmentMaxY >= 48.0 else { return }
//////                        print("DOWN currentOffsetY > requiredHeight, \(currentOffsetY > requiredHeight)", -segmentMaxY)
//////                        viewController.segmentControlView?.frame = CGRect(x: 0, y: segmentMaxY - 48.0, width: scrollView.bounds.width, height: 48.0)
//////                        viewController.blurryContainer?.frame = CGRect(x: 0, y: -segmentMaxY - 48.0, width: scrollView.bounds.width, height: 155.0)
//////                        viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                    } else if currentOffsetY < requiredHeight {
////                        guard -segmentMaxY <= 48.0 else { return }
//////                        print("DOWN currentOffsetY < requiredHeight, \(currentOffsetY < requiredHeight)", -segmentMaxY)
//////                        viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
//////                        viewController.blurryContainer?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 155.0)
//////                        viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
////                    }
////
////                    //self.removeGradientAndAddBlurness()
////                }
////            })
//    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("XX", velocity.y, targetContentOffset.pointee.y)
//    }
    
    private func removeGradientAndAddBlurness() {
        guard let viewController = viewModel.coordinator?.viewController else { return }
        
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
    }
    
    func setupGradient(with controller: HomeViewController) {
        gradientView?.layer.removeFromSuperlayer()
        
        guard !colors.isEmpty else { return }
        
        gradientView = UIView(frame: controller.blurryContainer.bounds)
        
        let color1 = colors[0]
        let color2 = colors[1]
        let color3 = colors[2]
        
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [color3.cgColor,
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






/*
 //                if currentOffsetY > .zero {
 //                    if isScrollingUp && currentOffsetY > 100 {
 //                        print("bigger up")
 //                        viewController.segmentControlView?.alpha = 1.0
 //                        viewController.segmentControlView?.frame = CGRect(x: 0, y: segmentY, width: scrollView.bounds.width, height: 48.0)
 //                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0 + 48.0
 //                    } else if !isScrollingUp && currentOffsetY < 100 {
 //                        print("bigger down")
 //                        viewController.segmentControlView?.alpha = .zero
 //                        viewController.segmentControlView?.frame = CGRect(x: 0, y: segmentY, width: scrollView.bounds.width, height: 48.0)
 //                        viewController.topContainerHeight.constant = -segmentMaxY + 96.0
 //                    }
 //                } else {
 //                    if segmentMaxY > .zero {
 //                        if isScrollingUp && currentOffsetY > 100 {
 //                            print("smaller up2")
 //                            viewController.segmentControlView?.alpha = 1.0
 //                            viewController.segmentControlView?.frame = CGRect(x: 0, y: segmentY, width: scrollView.bounds.width, height: 48.0)
 //                            viewController.topContainerHeight.constant = -segmentMaxY + 96.0 + 48.0
 //                        }
 //
 //                        self.gradientView.isNotNil
 //                            ? _ = (self.gradientView?.removeFromSuperview(),
 //                                   self.gradientView = nil)
 //                            : nil
 //                        self.blurView.isNil
 //                            ? _ = (viewController.blurryContainer.backgroundColor = .clear,
 //                                   self.blurView = UIVisualEffectView(effect: self.blurEffect),
 //                                   viewController.blurryContainer.insertSubview(self.blurView!, at: 0),
 //                                   self.blurView!.constraintToSuperview(viewController.blurryContainer))
 //                            : nil
 //                    } else {
 //                        if !isScrollingUp && currentOffsetY < 100 {
 //                            print("smaller down2")
 //                            viewController.segmentControlView?.alpha = .zero
 //                            viewController.segmentControlView?.frame = CGRect(x: 0, y: segmentY, width: scrollView.bounds.width, height: 48.0)
 //                            viewController.topContainerHeight.constant = -segmentMaxY + 96.0
 //                        }
 //
 //                        self.gradientView.isNil
 //                            ? viewController.dataSource?.setupGradient(with: viewController)
 //                            : nil
 //                        self.blurView.isNotNil
 //                            ? _ = (self.blurView?.removeFromSuperview(),
 //                                   self.blurView = nil)
 //                            : nil
 //                    }
 //                }
 */





/*
 func scrollViewDidScroll(_ scrollView: UIScrollView) {
     guard let viewController = viewModel.coordinator?.viewController,
           let view = viewController.view,
           let offsetY = scrollView.panGestureRecognizer.translation(in: view).y as CGFloat?
     else { return }
     
     let isScrollingUp = offsetY > .zero
     let topContainerHeight = viewController.topContainer.bounds.size.height
     let segmentContainerHeight = viewController.segmentViewContainer.bounds.size.height
     let currentOffsetY = scrollView.contentOffset.y
     
     let segmentY = min(0, -currentOffsetY - topContainerHeight - segmentContainerHeight)
     var segmentMaxY = max(0.0, -segmentY)
     segmentMaxY = segmentMaxY > 48.0 ? 48.0 : segmentMaxY
     let statusBarHeight: CGFloat = 59.0
     let requiredHeight: CGFloat = statusBarHeight + initialOffsetY
     
     printIfDebug(.debug, "CURRENT OFFSET Y: \(currentOffsetY), \(requiredHeight)")
//        printIfDebug(.debug, "SEGMENT Y: \(segmentY)")
     printIfDebug(.debug, "MAX SEGMENT Y: \(segmentMaxY)")
//        printIfDebug(.debug, "TOP CONTAINER HEIGHT: \(-segmentMaxY + 96.0)")
     
     UIView.animate(
         withDuration: 0.25,
         delay: .zero,
         options: .curveEaseInOut,
         animations: { [weak self] in
             guard let self = self else { return }
             if isScrollingUp {
                 if currentOffsetY < requiredHeight {
                     //up
                     print("currentOffsetY = requiredHeight", currentOffsetY <= requiredHeight)
                     viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                     viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                     viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
                     
                 } else if currentOffsetY == requiredHeight {
                     //up
                     print("currentOffsetY == requiredHeight", currentOffsetY <= requiredHeight)
                     viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY + 48.0, width: scrollView.bounds.width, height: 48.0)
                     viewController.topContainerHeight.constant = -segmentMaxY + 96.0 + 48.0
                     viewController.segmentControlView?.alpha = -segmentMaxY >= 0 ? 1.0 : .zero
                     
                 } else {
                     //down
                     print("else up")
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
                 }
                 if currentOffsetY > requiredHeight {
                     // down
                     print("currentOffsetY >= requiredHeight", currentOffsetY > requiredHeight)
                     viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY + 48.0, width: scrollView.bounds.width, height: 48.0)
                     viewController.topContainerHeight.constant = -segmentMaxY + 96.0 + 48.0
                     viewController.segmentControlView?.alpha = 1
                 } else {
                     //up
                     print("else up2")
                     viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                     viewController.topContainerHeight.constant = -segmentMaxY + 96.0
//                        viewController.segmentControlView?.alpha = 0
                     
                     if -currentOffsetY >= requiredHeight {
                         print("equals")
                         self.gradientView.isNil
                             ? viewController.dataSource?.setupGradient(with: viewController)
                             : nil
                         self.blurView.isNotNil
                             ? _ = (self.blurView?.removeFromSuperview(),
                                    self.blurView = nil)
                             : nil
                     }
                 }
                 
             } else {
                 if currentOffsetY > requiredHeight {
                     print("down close")
                     viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                     viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                     viewController.segmentControlView?.alpha = -segmentMaxY > 1 ? 1.0 : .zero
                 } else {
                     print("down else")
                     viewController.segmentControlView?.frame = CGRect(x: 0, y: -segmentMaxY, width: scrollView.bounds.width, height: 48.0)
                     viewController.topContainerHeight.constant = -segmentMaxY + 96.0
                     viewController.segmentControlView?.alpha = -segmentMaxY > 1 ? 1.0 : .zero
                 }
                 
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
             }
         })
 }
 */

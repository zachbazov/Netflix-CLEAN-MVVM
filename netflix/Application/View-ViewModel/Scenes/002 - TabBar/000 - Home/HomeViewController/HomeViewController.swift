//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    var dataSource: HomeTableViewDataSource? { get }
    var navigationView: NavigationView? { get }
    var browseOverlayView: BrowseOverlayView? { get }
}

// MARK: - HomeViewController Type

final class HomeViewController: Controller<HomeViewModel> {
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var blurryContainer: UIView!
    @IBOutlet private(set) var topContainer: UIView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var segmentViewContainer: UIView!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    @IBOutlet private(set) var topContainerHeight: NSLayoutConstraint!
    @IBOutlet private(set) var segmentContainerHeight: NSLayoutConstraint!
    @IBOutlet private(set) var navigationContainerBottom: NSLayoutConstraint!
    @IBOutlet private(set) var blurryContainerHeight: NSLayoutConstraint!
    
    private(set) var dataSource: HomeTableViewDataSource?
    var navigationView: NavigationView?
    var segmentControlView: SegmentControlView?
    var navigationOverlayView: NavigationOverlayView!
    var browseOverlayView: BrowseOverlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidBindObservers()
        viewDidDeploySubviews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.didLockDeviceOrientation(.portrait)
    }
    
    override func viewDidDeploySubviews() {
        setupDataSource()
        setupBlurryContainer()
        setupNavigationView()
        setupSegmentControlView()
        setupNavigationOverlay()
        setupBrowseOverlayView()
    }
    
    override func viewDidConfigure() {
        guard viewModel.isNotNil else { return }
        
        viewModel?.dataSourceState.value = .all
    }
    
    override func viewDidBindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            self.dataSource?.dataSourceDidChange()
        }
    }
    
    override func viewDidUnbindObservers() {
        guard viewModel.isNotNil else { return }
        
        viewModel.dataSourceState.remove(observer: self)
        
        printIfDebug(.success, "Removed `HomeViewModel` observers.")
    }
}

// MARK: - ViewControllerProtocol Implementation

extension HomeViewController: ViewControllerProtocol {}

// MARK: - Private UI Implementation

extension HomeViewController {
    private func setupDataSource() {
        dataSource = HomeTableViewDataSource(tableView: tableView, viewModel: viewModel)
    }
    
    private func setupBlurryContainer() {
//        let blurEffect = UIBlurEffect(style: .dark)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurryContainer.insertSubview(blurView, at: 0)
//        blurView.constraintToSuperview(blurryContainer)
    }
    
    private func setupNavigationView() {
        navigationView = NavigationView(on: navigationViewContainer, with: viewModel)
    }
    
    private func setupSegmentControlView() {
        segmentControlView = SegmentControlView(on: segmentViewContainer, with: viewModel)
    }
    
    private func setupNavigationOverlay() {
        navigationOverlayView = NavigationOverlayView(with: viewModel)
    }
    
    private func setupBrowseOverlayView() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
    }
}

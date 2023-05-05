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
    var navigationBar: NavigationBarView? { get }
    var navigationOverlay: NavigationOverlayView? { get }
    var browseOverlayView: BrowseOverlayView? { get }
    
    func createDataSource()
    func createNavigationBar()
    func createSegmentControl()
    func createNavigationOverlay()
    func createBrowseOverlay()
}

// MARK: - HomeViewController Type

final class HomeViewController: Controller<HomeViewModel> {
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var topContainer: UIView!
    @IBOutlet private(set) var navigationBarContainer: UIView!
    @IBOutlet private var segmentControlContainer: UIView!
    @IBOutlet private(set) var navigationOverlayContainer: UIView!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    @IBOutlet private(set) var topContainerHeight: NSLayoutConstraint!
    
    private(set) var dataSource: HomeTableViewDataSource?
    private(set) var navigationBar: NavigationBarView?
    private(set) var segmentControl: SegmentControlView?
    private(set) var navigationOverlay: NavigationOverlayView?
    private(set) var browseOverlayView: BrowseOverlayView?
    
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
        createDataSource()
        createNavigationBar()
        createSegmentControl()
        createNavigationOverlay()
        createBrowseOverlay()
    }
    
    override func viewDidConfigure() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.value = .all
    }
    
    override func viewDidBindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            self.dataSource?.dataSourceDidChange()
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.remove(observer: self)
        
        printIfDebug(.success, "Removed `HomeViewModel` observers.")
    }
}

// MARK: - ViewControllerProtocol Implementation

extension HomeViewController: ViewControllerProtocol {
    fileprivate func createDataSource() {
        dataSource = HomeTableViewDataSource(tableView: tableView, viewModel: viewModel)
    }
    
    fileprivate func createNavigationBar() {
        navigationBar = NavigationBarView(on: navigationBarContainer, with: viewModel)
    }
    
    fileprivate func createSegmentControl() {
        segmentControl = SegmentControlView(on: segmentControlContainer, with: viewModel)
    }
    
    fileprivate func createNavigationOverlay() {
        navigationOverlay = NavigationOverlayView(on: navigationOverlayContainer, with: viewModel)
    }
    
    fileprivate func createBrowseOverlay() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
    }
}

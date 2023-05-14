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
    var navigationOverlay: NavigationOverlayView? { get }
    var browseOverlayView: BrowseOverlayView? { get }
    
    func createDataSource()
    func createNavigationView()
    func createNavigationOverlay()
    func createBrowseOverlay()
}

// MARK: - HomeViewController Type

final class HomeViewController: Controller<HomeViewModel> {
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationOverlayViewContainer: UIView!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    @IBOutlet private(set) var navigationViewContainerHeight: NSLayoutConstraint!
    
    private(set) var dataSource: HomeTableViewDataSource?
    private(set) var navigationView: NavigationView?
    private(set) var navigationOverlay: NavigationOverlayView?
    private(set) var browseOverlayView: BrowseOverlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewWillLoadBehaviors()
        viewWillBindObservers()
        viewWillDeploySubviews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.deviceWillLockOrientation(.portrait)
    }
    
    override func viewWillDeploySubviews() {
        createDataSource()
        createNavigationView()
        createNavigationOverlay()
        createBrowseOverlay()
    }
    
    override func viewWillBindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.dataSource?.dataSourceWillChange()
        }
    }
    
    override func viewWillUnbindObservers() {
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
    
    fileprivate func createNavigationView() {
        navigationView = NavigationView(on: navigationViewContainer, with: viewModel)
    }
    
    fileprivate func createNavigationOverlay() {
        navigationOverlay = NavigationOverlayView(on: navigationOverlayViewContainer, with: viewModel)
    }
    
    fileprivate func createBrowseOverlay() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
    }
}

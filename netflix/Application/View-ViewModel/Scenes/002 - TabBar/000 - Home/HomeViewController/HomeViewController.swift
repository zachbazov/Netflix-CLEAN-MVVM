//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    var dataSource: MediaTableViewDataSource? { get }
    var navigationView: NavigationView? { get }
    var navigationOverlay: NavigationOverlayView? { get }
    var browseOverlayView: BrowseOverlayView? { get }
    
    func createDataSource()
    func createNavigationView()
    func createNavigationOverlay()
    func createBrowseOverlay()
}

// MARK: - HomeViewController Type

final class HomeViewController: UIViewController, Controller {
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationOverlayViewContainer: UIView!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    @IBOutlet private(set) var navigationViewContainerHeight: NSLayoutConstraint!
    
    var viewModel: HomeViewModel!
    
    private(set) var dataSource: MediaTableViewDataSource?
    private(set) var navigationView: NavigationView?
    private(set) var navigationOverlay: NavigationOverlayView?
    private(set) var browseOverlayView: BrowseOverlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillLoadBehaviors()
        viewWillBindObservers()
        viewWillDeploySubviews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceWillLockOrientation(.portrait)
    }
    
    func viewWillDeploySubviews() {
        createDataSource()
        createNavigationView()
        createNavigationOverlay()
        createBrowseOverlay()
    }
    
    func viewWillBindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.dataSource?.dataSourceWillChange()
        }
    }
    
    func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
}

// MARK: - ViewControllerProtocol Implementation

extension HomeViewController: ViewControllerProtocol {
    fileprivate func createDataSource() {
        dataSource = MediaTableViewDataSource(viewModel: viewModel)
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

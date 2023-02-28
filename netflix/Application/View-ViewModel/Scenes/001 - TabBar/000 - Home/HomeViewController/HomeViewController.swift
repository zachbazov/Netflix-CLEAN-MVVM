//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerOutput {
    var dataSource: HomeTableViewDataSource! { get }
    var navigationView: NavigationView! { get }
    var browseOverlayView: BrowseOverlayView! { get }
}

private typealias ViewControllerProtocol = ViewControllerOutput

// MARK: - HomeViewController Type

final class HomeViewController: Controller<HomeViewModel>, ViewControllerProtocol {
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    
    private(set) var dataSource: HomeTableViewDataSource!
    
    var navigationView: NavigationView!
    var browseOverlayView: BrowseOverlayView!
    var searchNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidConfigure()
        viewDidBindObservers()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.didLockDeviceOrientation(.portrait)
    }
    
    override func viewDidConfigure() {
        setupDataSource()
        setupNavigationView()
        setupBrowseOverlayView()
    }
    
    override func viewDidBindObservers() {
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            self?.dataSource.dataSourceDidChange()
        }
        viewModel.showcase.observe(on: self) { [weak self] in
            guard let media = $0 else { return }
            self?.navigationView.navigationOverlayView.opaqueView.viewDidUpdate(with: media)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        viewModel.dataSourceState.remove(observer: self)
        viewModel.showcase.remove(observer: self)
        printIfDebug(.success, "Removed `HomeViewModel` observers.")
    }
}

// MARK: - Private UI Implementation

extension HomeViewController {
    private func setupDataSource() {
        dataSource = HomeTableViewDataSource(tableView: tableView, viewModel: viewModel)
    }
    
    private func setupNavigationView() {
        navigationView = NavigationView(on: navigationViewContainer, with: viewModel)
    }
    
    private func setupBrowseOverlayView() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
        browseOverlayViewContainer.isHidden(true)
    }
}

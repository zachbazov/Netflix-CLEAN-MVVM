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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidDeployBehaviors()
        viewDidDeploySubviews()
        viewObserversDidBind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLockOrientation(.portrait)
    }
    
    override func viewDidDeploySubviews() {
        setupDataSource()
        setupNavigationView()
        setupBrowseOverlayView()
    }
    
    override func viewObserversDidBind() {
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            /// Release data source changes.
            self?.dataSource.dataSourceDidChange()
        }
        
        viewModel.showcase.observe(on: self) { [weak self] media in
            guard let media = media else { return }
            /// Release `opaqueView` view model changes based on the display media object.
            self?.navigationView.navigationOverlayView.opaqueView.viewModelDidUpdate(with: media)
        }
    }
    
    override func viewObserversDidUnbind() {
        if let viewModel = viewModel {
            printIfDebug(.success, "Removed `HomeViewModel` observers.")
            viewModel.dataSourceState.remove(observer: self)
            viewModel.showcase.remove(observer: self)
        }
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

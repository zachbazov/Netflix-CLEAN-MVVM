//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - HomeViewController Type

final class HomeViewController: UIViewController {
    
    // MARK: UIViewController Lifecycle Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: Outlet Properties
    
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    
    // MARK: Type's Properties
    
    var viewModel: HomeViewModel!
    var navigationView: NavigationView!
    var browseOverlayView: BrowseOverlayView!
    private(set) var dataSource: HomeTableViewDataSource!
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBehaviors()
        setupSubviews()
        setupObservers()
        viewModel.dataDidBeganLoading()
    }
}

// MARK: - UI Setup

extension HomeViewController {
    private func setupBehaviors() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    private func setupSubviews() {
        setupDataSource()
        setupNavigationView()
        setupBrowseOverlayView()
    }
    
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

// MARK: - Observers

extension HomeViewController {
    private func setupObservers() {
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            /// Release data source changes.
            self?.dataSource.dataSourceDidChange()
        }
        
        viewModel.displayMedia.observe(on: self) { [weak self] media in
            guard let media = media else { return }
            /// Release `opaqueView` view model changes based on the display media object.
            self?.navigationView.navigationOverlayView.opaqueView.viewModelDidUpdate(with: media)
        }
    }
    
    func removeObservers() {
        if let viewModel = viewModel {
            printIfDebug("Removed `HomeViewModel` observers.")
            viewModel.dataSourceState.remove(observer: self)
            viewModel.displayMedia.remove(observer: self)
        }
    }
}

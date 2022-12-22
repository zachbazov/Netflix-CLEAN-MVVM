//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

final class HomeViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    
    var viewModel: HomeViewModel!
    var navigationView: NavigationView!
    var browseOverlayView: BrowseOverlayView!
    private(set) var dataSource: HomeTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBehaviors()
        setupSubviews()
        setupObservers()
        viewModel.dataDidBeganLoading()
    }
    
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

extension HomeViewController {
    /// Deallocating this view controller entirely.
    func terminate() {
        /// Remove and deallocate navigation view and it's dependencies.
        navigationView.navigationOverlayView.removeFromSuperview()
        navigationView.navigationOverlayView = nil
        navigationView.removeFromSuperview()
        navigationView = nil
        /// Remove and deallocate browse overlay view.
        browseOverlayView.removeFromSuperview()
        browseOverlayView = nil
        /// Remove and deallocate home view model and it's dependencies.
        viewModel.myList.removeObservers()
        viewModel.myList = nil
        viewModel.coordinator = nil
        viewModel = nil
        /// Remove controller observers.
        removeObservers()
        /// Remove from tab bar controller.
        removeFromParent()
    }
}

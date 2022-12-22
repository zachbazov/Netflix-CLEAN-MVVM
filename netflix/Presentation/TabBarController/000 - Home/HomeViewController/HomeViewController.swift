//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

final class HomeViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    
    var viewModel: HomeViewModel!
    var navigationView: NavigationView!
    var browseOverlayView: BrowseOverlayView!
    var dataSource: HomeTableViewDataSource!
    
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
    
    private func setupObservers() {
        dataSourceState(in: viewModel)
        presentedDisplayMedia(in: viewModel)
    }
    
    private func setupDataSource() {
        /// Filters the sections based on the data source state.
        viewModel.filter(sections: viewModel.sections)
        
        dataSource = HomeTableViewDataSource(tableView: tableView, viewModel: viewModel)
    }
    
    private func setupNavigationView() {
        navigationView = NavigationView(on: navigationViewContainer, with: viewModel)
    }
    
    private func setupBrowseOverlayView() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
        browseOverlayViewContainer.isHidden(true)
    }
    
    func removeObservers() {
        if let viewModel = viewModel {
            printIfDebug("Removed `HomeViewModel` observers.")
            viewModel.dataSourceState.remove(observer: self)
            viewModel.presentedDisplayMedia.remove(observer: self)
        }
    }
    
    func terminate() {
        navigationView.navigationOverlayView.removeFromSuperview()
        navigationView.navigationOverlayView = nil
        
        navigationView.removeFromSuperview()
        navigationView = nil

        browseOverlayView.removeFromSuperview()
        browseOverlayView = nil
        
        viewModel.myList.removeObservers()
        viewModel.myList = nil
        viewModel.coordinator = nil
        viewModel = nil
        
        removeObservers()
        removeFromParent()
    }
}

extension HomeViewController {
    private func dataSourceState(in viewModel: HomeViewModel) {
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            self?.setupDataSource()
        }
    }
    
    private func presentedDisplayMedia(in viewModel: HomeViewModel) {
        viewModel.presentedDisplayMedia.observe(on: self) { [weak self] media in
            guard let media = media else { return }
            self?.navigationView.navigationOverlayView.opaqueView.viewModelDidUpdate(with: media)
        }
    }
}

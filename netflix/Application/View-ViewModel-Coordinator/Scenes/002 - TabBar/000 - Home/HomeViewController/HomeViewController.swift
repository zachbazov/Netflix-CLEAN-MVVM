//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - HomeViewController Type

final class HomeViewController: UIViewController, Controller {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.preferredStatusBarStyle
    }
    
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationOverlayViewContainer: UIView!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    @IBOutlet private(set) var navigationViewContainerHeight: NSLayoutConstraint!
    
    var viewModel: HomeViewModel!
    
    var dataSource: MediaTableViewDataSource?
    var navigationView: NavigationView?
    var navigationOverlay: NavigationOverlayView?
    var browseOverlayView: BrowseOverlayView?
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        restoreHomeViewControllerNavigationStyle()
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
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        tableView?.removeFromSuperview()
        
        navigationView?.viewWillDeallocate()
        navigationOverlay?.viewWillDeallocate()
        browseOverlayView?.viewWillDeallocate()
        
        dataSource = nil
        navigationView = nil
        navigationOverlay = nil
        browseOverlayView = nil
        
        viewModel?.coordinator?.viewController?.removeFromParent()
        viewModel?.coordinator?.account?.removeFromParent()
        viewModel?.coordinator?.detail?.removeFromParent()
        viewModel?.coordinator?.search?.removeFromParent()
        
        viewModel?.coordinator?.viewController = nil
        viewModel?.coordinator = nil
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - Private Implementation

extension HomeViewController {
    private func createDataSource() {
        dataSource = MediaTableViewDataSource(viewModel: viewModel)
    }
    
    private func createNavigationView() {
        navigationView = NavigationView(with: viewModel)
        navigationView?
            .addToHierarchy(on: navigationViewContainer)
            .constraintToSuperview(navigationViewContainer)
    }
    
    private func createNavigationOverlay() {
        navigationOverlay = NavigationOverlayView(on: navigationOverlayViewContainer, with: viewModel)
    }
    
    private func createBrowseOverlay() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
    }
    
    private func restoreHomeViewControllerNavigationStyle() {
        if navigationView?.gradient == nil || navigationView?.blur == nil {
            
            mainQueueDispatch { [weak self] in
                guard let self = self else { return }
                
                self.navigationView?.segmentControl?.origin(y: .zero)
                self.navigationViewContainerHeight.constant = 160.0
                self.navigationView?.segmentControl?.alpha = 1.0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.tableView.contentOffset.y < .zero {
                        self.navigationView?.apply(.gradient)
                    } else {
                        self.navigationView?.apply(.blur)
                    }
                    
                    self.navigationView?.layoutIfNeeded()
                }
            }
        }
    }
}

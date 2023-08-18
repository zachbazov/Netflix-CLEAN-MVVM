//
//  DownloadsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - DownloadsViewController Type

final class DownloadsViewController: UIViewController, Controller {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private var downloadsViewContainer: UIView!
    
    var viewModel: DownloadsViewModel!
    
    var navigationView: DownloadsNavigationView?
    var downloadsView: DownloadsView?
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        navigationView = createDownloadsNavigationView()
        downloadsView = createDownloadsView()
    }
    
    func viewHierarchyWillConfigure() {
        navigationView?
            .addToHierarchy(on: navigationViewContainer)
            .constraintToSuperview(navigationViewContainer)
        
        downloadsView?
            .addToHierarchy(on: downloadsViewContainer)
            .constraintToSuperview(downloadsViewContainer)
    }
    
    func viewWillDeallocate() {
        navigationView?.removeFromSuperview()
        navigationView = nil
        downloadsView?.removeFromSuperview()
        downloadsView = nil
        
        viewModel?.coordinator?.viewController = nil
        viewModel?.coordinator = nil
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - Private Implementation

extension DownloadsViewController {
    private func createDownloadsNavigationView() -> DownloadsNavigationView {
        return DownloadsNavigationView()
    }
    
    private func createDownloadsView() -> DownloadsView {
        return DownloadsView()
    }
}

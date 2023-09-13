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
    
    lazy var navigationView: DownloadsNavigationView? = createDownloadsNavigationView()
    lazy var downloadsView: DownloadsView? = createDownloadsView()
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHierarchyDidConfigure()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDeallocate()
    }
    
    func viewHierarchyDidConfigure() {
        navigationView?
            .addToHierarchy(on: navigationViewContainer)
            .constraintToSuperview(navigationViewContainer)
        
        downloadsView?
            .addToHierarchy(on: downloadsViewContainer)
            .constraintToSuperview(downloadsViewContainer)
    }
    
    func viewDidDeallocate() {
        navigationView?.removeFromSuperview()
        navigationView = nil
        downloadsView?.removeFromSuperview()
        downloadsView = nil
        
        viewModel?.coordinator?.viewController = nil
        viewModel?.coordinator = nil
        viewModel = nil
        
        navigationController?.viewControllers.removeAll()
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

//
//  DownloadsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerProtocol {
    var navigationView: DownloadsNavigationView { get }
    var downloadsView: DownloadsView { get }
}

// MARK: - DownloadsViewController Type

final class DownloadsViewController: Controller<DownloadsViewModel> {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private var downloadsViewContainer: UIView!
    
    fileprivate lazy var navigationView: DownloadsNavigationView = createDownloadsNavigationView()
    fileprivate lazy var downloadsView: DownloadsView = createDownloadsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHierarchyWillConfigure()
    }
    
    override func viewHierarchyWillConfigure() {
        navigationView
            .addToHierarchy(on: navigationViewContainer)
            .constraintToSuperview(navigationViewContainer)
        
        downloadsView
            .addToHierarchy(on: downloadsViewContainer)
            .constraintToSuperview(downloadsViewContainer)
    }
}

// MARK: - ControllerProtocol Implementation

extension DownloadsViewController: ControllerProtocol {}

// MARK: - Private Implementation

extension DownloadsViewController {
    private func createDownloadsNavigationView() -> DownloadsNavigationView {
        return DownloadsNavigationView()
    }
    
    private func createDownloadsView() -> DownloadsView {
        return DownloadsView()
    }
}

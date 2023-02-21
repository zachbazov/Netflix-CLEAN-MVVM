//
//  DownloadsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerOutput {
    var navigationView: DownloadsNavigationView! { get }
    var downloadsView: DownloadsView! { get }
}

private typealias ControllerProtocol = ControllerOutput

// MARK: - DownloadsViewController Type

final class DownloadsViewController: Controller<DownloadsViewModel> {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private var downloadsViewContainer: UIView!
    
    fileprivate var navigationView: DownloadsNavigationView!
    fileprivate var downloadsView: DownloadsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
    }
    
    override func viewDidDeploySubviews() {
        setupDownloadsNavigationView()
        setupDownloadsView()
    }
}

// MARK: - ControllerProtocol Implementation

extension DownloadsViewController: ControllerProtocol {}

// MARK: - Private UI Implementation

extension DownloadsViewController {
    private func setupDownloadsNavigationView() {
        navigationView = DownloadsNavigationView(on: navigationViewContainer)
    }
    
    private func setupDownloadsView() {
        downloadsView = DownloadsView(on: downloadsViewContainer)
    }
}

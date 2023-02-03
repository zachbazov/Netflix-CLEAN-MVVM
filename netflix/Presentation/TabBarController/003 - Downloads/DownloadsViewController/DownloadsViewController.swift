//
//  DownloadsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - DownloadsViewController Type

final class DownloadsViewController: UIViewController {
    @IBOutlet private var navigationViewContainer: UIView!
    @IBOutlet private var downloadsViewContainer: UIView!
    
    var viewModel: DownloadsViewModel!
    private var navigationView: DownloadsNavigationView!
    private var downloadsView: DownloadsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
}

// MARK: - UI Setup

extension DownloadsViewController {
    private func setupSubviews() {
        setupDownloadsNavigationView()
        setupDownloadsView()
    }
    
    private func setupDownloadsNavigationView() {
        navigationView = DownloadsNavigationView(on: navigationViewContainer)
    }
    
    private func setupDownloadsView() {
        downloadsView = DownloadsView(on: downloadsViewContainer)
    }
}

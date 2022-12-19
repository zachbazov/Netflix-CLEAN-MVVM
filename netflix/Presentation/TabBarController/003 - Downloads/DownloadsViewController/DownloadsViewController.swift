//
//  DownloadsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

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
    
    private func setupSubviews() {
        setupDownloadsNavigationView()
        setupDownloadsView()
    }
    
    private func setupDownloadsNavigationView() {
        navigationView = DownloadsNavigationView(frame: navigationViewContainer.bounds)
        navigationViewContainer.addSubview(navigationView)
    }
    
    private func setupDownloadsView() {
        downloadsView = DownloadsView(frame: downloadsViewContainer.bounds)
        downloadsViewContainer.addSubview(downloadsView)
    }
}

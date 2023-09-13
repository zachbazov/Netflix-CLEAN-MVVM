//
//  MyNetflixViewController.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import UIKit

// MARK: - MyNetflixViewController Type

final class MyNetflixViewController: UIViewController, Controller {
    @IBOutlet private(set) weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.preferredStatusBarStyle
    }
    
    var viewModel: MyNetflixViewModel!
    
    var dataSource: AccountTableViewDataSource?
    
    deinit {
        viewDidDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidConfigure()
    }
    
    func viewDidDeploySubviews() {
        createDataSource()
    }
    
    func viewDidConfigure() {
        
    }
    
    func viewDidBindObservers() {
        
    }
    
    func viewDidUnbindObservers() {
        
    }
    
    func viewDidDeallocate() {
        dataSource = nil
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - Private Implementation

extension MyNetflixViewController {
    private func createDataSource() {
        dataSource = AccountTableViewDataSource(with: viewModel)
    }
}

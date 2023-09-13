//
//  NotificationsViewController.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import UIKit

// MARK: - NotificationsViewController Type

final class NotificationsViewController: UIViewController, Controller {
    var viewModel: NotificationsViewModel!
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDeallocate()
    }
    
    func viewDidDeallocate() {
        viewModel?.coordinator?.viewController = nil
        viewModel?.coordinator = nil
        viewModel = nil
        
        navigationController?.viewControllers.removeAll()
        removeFromParent()
    }
}

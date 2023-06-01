//
//  FastLaughsViewController.swift
//  netflix
//
//  Created by Zach Bazov on 28/02/2023.
//

import UIKit

// MARK: - FastLaughsViewController Type

final class FastLaughsViewController: UIViewController, Controller {
    var viewModel: FastLaughsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewWillDeallocate() {
//        viewModel?.coordinator?.viewController?.viewModel = nil
//        viewModel?.coordinator?.viewController = nil
        viewModel?.coordinator = nil
        viewModel = nil
        
        removeFromParent()
    }
}

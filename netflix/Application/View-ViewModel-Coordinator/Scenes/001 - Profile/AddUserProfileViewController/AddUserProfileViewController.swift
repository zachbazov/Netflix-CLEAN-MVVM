//
//  AddUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - AddUserProfileViewController Type

final class AddUserProfileViewController: UIViewController, Controller {
    var viewModel: ProfileViewModel!
    
    deinit {
        viewModel = nil
        
        removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
}

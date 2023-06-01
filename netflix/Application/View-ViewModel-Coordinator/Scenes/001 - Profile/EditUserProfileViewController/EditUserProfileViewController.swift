//
//  EditUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - EditUserProfileViewController Type

final class EditUserProfileViewController: UIViewController, Controller {
    var viewModel: ProfileViewModel!
    
    deinit {
        viewModel = nil
        
        removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
    }
}

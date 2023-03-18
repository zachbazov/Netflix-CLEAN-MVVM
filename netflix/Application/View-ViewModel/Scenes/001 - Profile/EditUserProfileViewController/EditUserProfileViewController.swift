//
//  EditUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerInput {
    
}

private protocol ViewControllerOutput {
    
}

private typealias ViewControllerProtocol = ViewControllerInput & ViewControllerOutput

// MARK: - EditUserProfileViewController Type

final class EditUserProfileViewController: Controller<ProfileViewModel> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
    }
}

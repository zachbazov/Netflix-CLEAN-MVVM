//
//  AddUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {}

// MARK: - AddUserProfileViewController Type

final class AddUserProfileViewController: Controller<ProfileViewModel> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
}

// MARK: - ViewControllerProtocol Implementation

extension AddUserProfileViewController: ViewControllerProtocol {}

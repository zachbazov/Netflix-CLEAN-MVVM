//
//  ProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - ProfileViewController Type

final class ProfileViewController: Controller<ProfileViewModel> {
    deinit {
        print("deinit \(String(describing: Self.self))")
    }
}

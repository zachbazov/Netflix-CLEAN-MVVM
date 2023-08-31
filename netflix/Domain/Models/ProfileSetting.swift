//
//  ProfileSetting.swift
//  netflix
//
//  Created by Developer on 24/08/2023.
//

import Foundation

// MARK: - ProfileSetting Type

struct ProfileSetting {
    let image: String
    let title: String
    var subtitle: String? = nil
    let hasSubtitle: Bool
    let isSwitchable: Bool
}

//
//  ProfileSettingTableViewCellViewModel.swift
//  netflix
//
//  Created by Developer on 24/08/2023.
//

import Foundation

// MARK: - ProfileSettingTableViewCellViewModel Type

struct ProfileSettingTableViewCellViewModel {
    let image: String
    let title: String
    var subtitle: String?
    let cellType: ProfileSettingTableViewCellType
    
    init?(at indexPath: IndexPath, with viewModel: ProfileViewModel) {
        let profileSetting = viewModel.profileSettings[indexPath.section]
        
        self.image = profileSetting.image
        self.title = profileSetting.title
        self.subtitle = profileSetting.subtitle
        self.cellType = profileSetting.isSwitchable ? .switchable : .selectable
    }
}

// MARK: - ViewModel Implementation

extension ProfileSettingTableViewCellViewModel: ViewModel {}

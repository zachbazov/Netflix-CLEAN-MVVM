//
//  ProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import Foundation

// MARK: - ProfileCollectionViewCellViewModel Type

struct ProfileCollectionViewCellViewModel {
    let image: String
    let name: String
    
    init(with profile: Profile) {
        self.image = profile.image
        self.name = profile.name
    }
}

// MARK: - ViewModel Implementation

extension ProfileCollectionViewCellViewModel: ViewModel {}

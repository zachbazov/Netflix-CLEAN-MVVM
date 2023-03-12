//
//  ProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

struct ProfileCollectionViewCellViewModel {
    let image: String
    let name: String
    
    init(with profile: ProfileItem) {
        self.image = profile.image
        self.name = profile.name
    }
}

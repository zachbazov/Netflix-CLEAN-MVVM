//
//  ProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ModelProtocol Type

private protocol ModelInput {
    init(with profile: ProfileItem)
}

private protocol ModelOutput {
    var image: String { get }
    var name: String { get }
}

private typealias ModelProtocol = ModelInput & ModelOutput

// MARK: - ProfileCollectionViewCellViewModel Type

struct ProfileCollectionViewCellViewModel {
    let image: String
    let name: String
    
    init(with profile: ProfileItem) {
        self.image = profile.image
        self.name = profile.name
    }
    
    init(with profile: UserProfile) {
        self.image = profile.image
        self.name = profile.name
    }
}

// MARK: - ModelProtocol Implementation

extension ProfileCollectionViewCellViewModel: ModelProtocol {}

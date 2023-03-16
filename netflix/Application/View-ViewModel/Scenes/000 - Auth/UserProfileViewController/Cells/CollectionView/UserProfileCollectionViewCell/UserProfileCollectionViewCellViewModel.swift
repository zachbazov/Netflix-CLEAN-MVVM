//
//  UserProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import Foundation

// MARK: - ModelProtocol Type

private protocol ModelInput {
    init(with profile: UserProfile)
}

private protocol ModelOutput {
    var image: String { get }
    var name: String { get }
}

private typealias ModelProtocol = ModelInput & ModelOutput

// MARK: - UserProfileCollectionViewCellViewModel Type

struct UserProfileCollectionViewCellViewModel {
    let image: String
    let name: String
    
    init(with profile: UserProfile) {
        self.image = profile.image
        self.name = profile.name
    }
}

// MARK: - ModelProtocol Implementation

extension UserProfileCollectionViewCellViewModel: ModelProtocol {}

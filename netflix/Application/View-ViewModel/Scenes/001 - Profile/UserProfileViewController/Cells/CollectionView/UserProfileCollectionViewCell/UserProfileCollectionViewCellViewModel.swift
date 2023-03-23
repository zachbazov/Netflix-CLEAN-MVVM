//
//  UserProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import Foundation

// MARK: - ModelProtocol Type

private protocol ModelProtocol {
    var image: String { get }
    var name: String { get }
}

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

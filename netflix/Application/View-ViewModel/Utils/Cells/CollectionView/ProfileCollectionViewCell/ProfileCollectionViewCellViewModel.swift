//
//  ProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var image: String { get }
    var name: String { get }
    
    init(with profile: UserProfile)
}

// MARK: - ProfileCollectionViewCellViewModel Type

struct ProfileCollectionViewCellViewModel {
    let image: String
    let name: String
    
    init(with profile: UserProfile) {
        self.image = profile.image
        self.name = profile.name
    }
}

// MARK: - ViewModel Implementation

extension ProfileCollectionViewCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension ProfileCollectionViewCellViewModel: ViewModelProtocol {}

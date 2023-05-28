//
//  AccountProfileCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var image: String { get }
    var name: String { get }
    
    init(with profile: Profile)
}

// MARK: - AccountProfileCollectionViewCellViewModel Type

struct AccountProfileCollectionViewCellViewModel {
    let image: String
    let name: String
    
    init(with profile: Profile) {
        self.image = profile.image
        self.name = profile.name
    }
}

// MARK: - ViewModel Implementation

extension AccountProfileCollectionViewCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension AccountProfileCollectionViewCellViewModel: ViewModelProtocol {}

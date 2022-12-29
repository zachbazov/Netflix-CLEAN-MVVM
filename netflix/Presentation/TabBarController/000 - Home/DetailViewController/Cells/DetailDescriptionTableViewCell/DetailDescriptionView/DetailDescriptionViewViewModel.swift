//
//  DetailDescriptionViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - DetailDescriptionViewViewModel Type

struct DetailDescriptionViewViewModel {
    
    // MARK: Properties
    
    let description: String
    let cast: String
    let writers: String
    
    // MARK: Initializer
    
    /// Create a description view view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media) {
        self.description = media.description
        self.cast = media.cast
        self.writers = media.writers
    }
}

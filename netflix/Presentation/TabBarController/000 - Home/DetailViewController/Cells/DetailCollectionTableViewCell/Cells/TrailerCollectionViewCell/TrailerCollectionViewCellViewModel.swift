//
//  TrailerCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - TrailerCollectionViewCellViewModel Type

struct TrailerCollectionViewCellViewModel {
    
    // MARK: Properties
    
    let title: String
    var posterImagePath: String
    var posterImageIdentifier: NSString
    var posterImageURL: URL!
    
    // MARK: Initializer
    
    /// Create a trailer collection view cell view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media) {
        self.title = media.title
        self.posterImagePath = media.resources.previewPoster
        self.posterImageIdentifier = .init(string: "detail-poster_\(media.slug)")
        self.posterImageURL = .init(string: self.posterImagePath)
    }
}

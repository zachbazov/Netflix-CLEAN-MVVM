//
//  CollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/09/2022.
//

import Foundation

// MARK: - CollectionViewCellViewModel Type

struct CollectionViewCellViewModel: Equatable {
    
    // MARK: Properties
    
    let indexPath: IndexPath
    let title: String
    let slug: String
    let posters: [String]
    let logos: [String]
    var posterImagePath: String
    var posterImageIdentifier: NSString
    var posterImageURL: URL!
    var logoImagePath: String
    var logoImageIdentifier: NSString
    var logoImageURL: URL!
    let presentedLogoAlignment: PresentedLogoAlignment
    
    // MARK: Initializer
    
    /// Create a collection view cell view model object.
    /// - Parameters:
    ///   - media: Represented media object.
    ///   - indexPath: Represented index path for the object on the collection.
    init(media: Media, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.title = media.title
        self.slug = media.slug
        self.posters = media.resources.posters
        self.logos = media.resources.logos
        self.posterImagePath = .init()
        self.logoImagePath = .init()
        self.presentedLogoAlignment = .init(rawValue: media.resources.presentedLogoAlignment)!
        self.posterImageIdentifier = .init(string: "poster_\(media.slug)")
        self.logoImageIdentifier = .init(string: "logo_\(media.slug)")
        self.posterImagePath = media.path(forResourceOfType: PresentedPoster.self)!
        self.logoImagePath = media.path(forResourceOfType: PresentedLogo.self)!
        self.posterImageURL = URL(string: self.posterImagePath)
        self.logoImageURL = URL(string: self.logoImagePath)
    }
}

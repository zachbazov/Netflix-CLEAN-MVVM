//
//  SearchCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import Foundation

// MARK: - SearchCollectionViewCellViewModel Type

struct SearchCollectionViewCellViewModel {
    
    // MARK: Properties
    
    var media: Media?
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
    
    /// Create a search collection view cell view model object.
    /// - Parameter media: Corresponding media object.
    init(media: Media) {
        self.media = media
        self.title = media.title
        self.slug = media.slug
        self.posters = media.resources.posters
        self.logos = media.resources.logos
        self.posterImagePath = .init()
        self.logoImagePath = .init()
        self.presentedLogoAlignment = .init(rawValue: media.resources.presentedLogoAlignment)!
        self.posterImageIdentifier = .init(string: "preview-poster_\(media.slug)")
        self.logoImageIdentifier = .init(string: "display-logo_\(media.slug)")
        self.posterImagePath = media.resources.previewPoster
        self.logoImagePath = media.path(forResourceOfType: PresentedDisplayLogo.self)!
        self.posterImageURL = URL(string: self.posterImagePath)
        self.logoImageURL = URL(string: self.logoImagePath)
    }
}

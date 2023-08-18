//
//  SearchCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media? { get }
    var title: String { get }
    var slug: String { get }
    var posters: [String] { get }
    var logos: [String] { get }
    var posterImagePath: String { get }
    var posterImageIdentifier: NSString { get }
    var posterImageURL: URL! { get }
    var logoImagePath: String { get }
    var logoImageIdentifier: NSString { get }
    var logoImageURL: URL! { get }
    var presentedLogoAlignment: PresentedLogoAlignment { get }
    var presentedSearchLogoAlignment: PresentedSearchLogoAlignment { get }
}

// MARK: - SearchCollectionViewCellViewModel Type

struct SearchCollectionViewCellViewModel {
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
    var presentedSearchLogoAlignment: PresentedSearchLogoAlignment
    
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
        self.presentedLogoAlignment = PresentedLogoAlignment(rawValue: media.resources.presentedSearchLogoAlignment) ?? .bottom
        self.presentedSearchLogoAlignment = PresentedSearchLogoAlignment(rawValue: media.resources.presentedSearchLogoAlignment) ?? .maxXmaxY
        self.posterImageIdentifier = .init(string: "preview-poster_\(media.slug)")
        self.logoImageIdentifier = .init(string: "display-logo_\(media.slug)")
        self.posterImagePath = media.resources.previewPoster
        self.logoImagePath = media.path(forResourceOfType: PresentedSearchLogo.self)
        self.posterImageURL = URL(string: Application.app.configuration.api.urlString + self.posterImagePath)
        self.logoImageURL = URL(string: Application.app.configuration.api.urlString + self.logoImagePath)
    }
}

// MARK: - ViewModel Implementation

extension SearchCollectionViewCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension SearchCollectionViewCellViewModel: ViewModelProtocol {}

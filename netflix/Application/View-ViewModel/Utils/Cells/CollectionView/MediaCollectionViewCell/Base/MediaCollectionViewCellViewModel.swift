//
//  MediaCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
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
}

// MARK: - MediaCollectionViewCellViewModel Type

struct MediaCollectionViewCellViewModel {
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
    
    /// Create a collection view cell view model object.
    /// - Parameters:
    ///   - media: Represented media object.
    ///   - indexPath: Represented index path for the object on the collection.
    init(media: Media) {
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

// MARK: - ViewModel Implementation

extension MediaCollectionViewCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension MediaCollectionViewCellViewModel: ViewModelProtocol {}

// MARK: - Equatable Implementation

extension MediaCollectionViewCellViewModel: Equatable {}

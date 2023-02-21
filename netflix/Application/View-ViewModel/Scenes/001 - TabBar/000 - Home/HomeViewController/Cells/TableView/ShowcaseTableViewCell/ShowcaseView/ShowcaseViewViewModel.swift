//
//  ShowcaseViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var slug: String { get }
    var genres: [String] { get }
    var posterImagePath: String { get }
    var posterImageIdentifier: NSString { get }
    var posterImageURL: URL! { get }
    var logoImagePath: String { get }
    var logoImageIdentifier: NSString { get }
    var logoImageURL: URL! { get }
    var attributedGenres: NSMutableAttributedString! { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - ShowcaseViewViewModel Type

struct ShowcaseViewViewModel {
    let slug: String
    let genres: [String]
    let posterImagePath: String
    var posterImageIdentifier: NSString
    var posterImageURL: URL!
    var logoImagePath: String
    var logoImageIdentifier: NSString
    var logoImageURL: URL!
    var attributedGenres: NSMutableAttributedString!
    /// Create a view model based on a media object.
    /// - Parameter media: The media object represented on the display view.
    init(with media: Media) {
        self.slug = media.slug
        self.posterImagePath = media.resources.displayPoster
        self.logoImagePath = .init()
        self.genres = media.genres
        self.attributedGenres = .init()
        self.posterImageIdentifier = .init(string: "display-poster_\(media.slug)")
        self.logoImageIdentifier = .init(string: "display-logo_\(media.slug)")
        self.logoImagePath = media.path(forResourceOfType: PresentedDisplayLogo.self)!
        self.posterImageURL = .init(string: self.posterImagePath)
        self.logoImageURL = .init(string: self.logoImagePath)
        self.attributedGenres = media.attributedString(for: .display)
    }
}

// MARK: - ViewModel Implementation

extension ShowcaseViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension ShowcaseViewViewModel: ViewModelProtocol {}

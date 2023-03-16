//
//  NewsCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var media: Media { get }
    var previewPosterImagePath: String { get }
    var previewPosterImageIdentifier: NSString { get }
    var previewPosterImageURL: URL! { get }
    var displayLogoImagePath: String { get }
    var displayLogoImageIdentifier: NSString { get }
    var displayLogoImageURL: URL! { get }
    var eta: String { get }
    var mediaType: String { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - NewsCollectionViewCellViewModel Type

struct NewsCollectionViewCellViewModel {
    let media: Media
    let previewPosterImagePath: String
    let previewPosterImageIdentifier: NSString
    var previewPosterImageURL: URL!
    let displayLogoImagePath: String
    let displayLogoImageIdentifier: NSString
    var displayLogoImageURL: URL!
    let eta: String
    let mediaType: String
    /// Create a news table view cell view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media) {
        self.media = media
        self.previewPosterImagePath = media.resources.previewPoster
        self.previewPosterImageIdentifier = "preview-poster_\(media.slug)" as NSString
        self.previewPosterImageURL = URL(string: self.previewPosterImagePath)
        self.displayLogoImagePath = media.path(forResourceOfType: PresentedDisplayLogo.self)!
        self.displayLogoImageIdentifier = "display-logo_\(media.slug)" as NSString
        self.displayLogoImageURL = URL(string: self.displayLogoImagePath)
        self.eta = ["Coming Soon", "In \(Int.random(in: 1...60)) Days"].randomElement()!
        self.mediaType = media.type == "series" ? "S E R I E" : "F I L M"
    }
}

// MARK: - ViewModelProtocol Implementation

extension NewsCollectionViewCellViewModel: ViewModelProtocol {}

// MARK: - Equatable Implementation

extension NewsCollectionViewCellViewModel: Equatable {
    static func ==(lhs: NewsCollectionViewCellViewModel, rhs: NewsCollectionViewCellViewModel) -> Bool {
        return lhs.media.slug == rhs.media.slug
    }
}

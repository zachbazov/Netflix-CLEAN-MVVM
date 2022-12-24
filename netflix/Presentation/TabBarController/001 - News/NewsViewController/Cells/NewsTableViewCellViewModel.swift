//
//  NewsTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

struct NewsTableViewCellViewModel {
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
        self.mediaType = media.type == .series ? "S E R I E" : "F I L M"
    }
}

extension NewsTableViewCellViewModel: Equatable {
    static func ==(lhs: NewsTableViewCellViewModel, rhs: NewsTableViewCellViewModel) -> Bool {
        return lhs.media.slug == rhs.media.slug
    }
}

//
//  TrailerCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var title: String { get }
    var posterImagePath: String { get }
    var posterImageIdentifier: NSString { get }
    var posterImageURL: URL! { get }
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - TrailerCollectionViewCellViewModel Type

struct TrailerCollectionViewCellViewModel {
    let title: String
    var posterImagePath: String
    var posterImageIdentifier: NSString
    var posterImageURL: URL!
    /// Create a trailer collection view cell view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media) {
        self.title = media.title
        self.posterImagePath = media.resources.previewPoster
        self.posterImageIdentifier = .init(string: "detail-poster_\(media.slug)")
        self.posterImageURL = .init(string: self.posterImagePath)
    }
}

// MARK: - ViewModelProtocol Implementation

extension TrailerCollectionViewCellViewModel: ViewModelProtocol {}

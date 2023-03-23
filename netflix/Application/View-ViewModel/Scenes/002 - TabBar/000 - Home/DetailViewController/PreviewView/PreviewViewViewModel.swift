//
//  PreviewViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var title: String { get }
    var slug: String { get }
    var posterImagePath: String { get }
    var identifier: NSString { get }
    var url: URL { get }
}

// MARK: - PreviewViewViewModel Type

struct PreviewViewViewModel {
    let title: String
    let slug: String
    let posterImagePath: String
    let identifier: NSString
    let url: URL
    
    /// Create a preview view view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media) {
        self.title = media.title
        self.slug = media.slug
        self.posterImagePath = media.resources.previewPoster
        self.identifier = "detail-poster_\(media.slug)" as NSString
        self.url = URL(string: self.posterImagePath)!
    }
}

// MARK: - ViewModel Implementation

extension PreviewViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension PreviewViewViewModel: ViewModelProtocol {}

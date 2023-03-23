//
//  OpaqueViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var imagePath: String { get }
    var identifier: NSString { get }
    var imageURL: URL { get }
}

// MARK: - OpaqueViewViewModel Type

struct OpaqueViewViewModel {
    let imagePath: String
    let identifier: NSString
    let imageURL: URL
    
    /// Create a opaque view view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media) {
        self.imagePath = media.resources.displayPoster
        self.identifier = "display-poster_\(media.slug)" as NSString
        self.imageURL = URL(string: self.imagePath)!
    }
}

// MARK: - ViewModel Implementation

extension OpaqueViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension OpaqueViewViewModel: ViewModelProtocol {}

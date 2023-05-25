//
//  DetailCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 24/05/2023.
//

import Foundation

// MARK: - DetailCollectionViewCellViewModel Type

struct DetailCollectionViewCellViewModel {
    let title: String
    let slug: String
    let length: String
    let description: String
    let posterImagePath: String
    let posterImageIdentifier: NSString
    var posterImageURL: URL!
    var season: Season?
    
    init(with viewModel: DetailViewModel) {
        guard let media = viewModel.media else { fatalError() }
        
        self.title = media.title
        self.slug = media.slug
        self.length = media.length
        self.description = media.description
        self.posterImagePath = media.resources.previewPoster
        self.posterImageIdentifier = .init(string: "detail-poster_\(media.slug)")
        self.posterImageURL = .init(string: self.posterImagePath)
        
        if let dataSource = viewModel.coordinator?.viewController?.dataSource,
           let collectionCell = dataSource.collectionCell {
            self.season = collectionCell.viewModel?.season.value
        }
    }
}

// MARK: - ViewModel Implementation

extension DetailCollectionViewCellViewModel: ViewModel {}

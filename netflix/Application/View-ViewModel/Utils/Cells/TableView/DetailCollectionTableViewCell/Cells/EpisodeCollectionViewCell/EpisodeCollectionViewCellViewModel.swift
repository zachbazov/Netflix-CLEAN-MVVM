//
//  EpisodeCollectionViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 12/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media { get }
    var posterImagePath: String { get }
    var posterImageIdentifier: NSString { get }
    var posterImageURL: URL! { get }
    var season: Season? { get }
}

// MARK: - EpisodeCollectionViewCellViewModel Type

struct EpisodeCollectionViewCellViewModel {
    let media: Media
    let posterImagePath: String
    let posterImageIdentifier: NSString
    var posterImageURL: URL!
    var season: Season?
    
    /// Create an episode collection view cell view model object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: DetailViewModel) {
        guard let media = viewModel.media else { fatalError() }
        
        self.media = media
        self.posterImagePath = self.media.resources.previewPoster
        self.posterImageIdentifier = .init(string: "detail-poster_\(self.media.slug)")
        self.posterImageURL = .init(string: self.posterImagePath)
        
        if let dataSource = viewModel.coordinator?.viewController?.dataSource,
           let collection = dataSource.collectionCell?.detailCollectionView {
            self.season = collection.viewModel.season.value
        }
    }
}

// MARK: - ViewModel Implementation

extension EpisodeCollectionViewCellViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension EpisodeCollectionViewCellViewModel: ViewModelProtocol {}

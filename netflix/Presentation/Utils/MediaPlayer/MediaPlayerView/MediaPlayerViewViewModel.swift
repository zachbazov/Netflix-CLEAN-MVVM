//
//  MediaPlayerView.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import Foundation

// MARK: - MediaPlayerViewViewModel Type

struct MediaPlayerViewViewModel {
    
    // MARK: Properties
    
    let media: Media
    let item: MediaPlayerViewItem?
    var isPlaying: Bool
    
    // MARK: Initializer
    
    init(with viewModel: DetailViewModel) {
        self.media = viewModel.media
        self.item = .init(with: self.media)
        self.isPlaying = false
    }
}

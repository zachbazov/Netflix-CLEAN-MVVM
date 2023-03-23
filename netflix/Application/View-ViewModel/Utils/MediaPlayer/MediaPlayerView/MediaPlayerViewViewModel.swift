//
//  MediaPlayerView.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var media: Media { get }
    var item: MediaPlayerViewItem? { get }
    var isPlaying: Bool { get }
}

// MARK: - MediaPlayerViewViewModel Type

struct MediaPlayerViewViewModel {
    let media: Media
    let item: MediaPlayerViewItem?
    var isPlaying: Bool
    
    init(with viewModel: DetailViewModel) {
        self.media = viewModel.media
        self.item = .init(with: self.media)
        self.isPlaying = false
    }
}

extension MediaPlayerViewViewModel: ViewModel {}

extension MediaPlayerViewViewModel: ViewModelProtocol {}

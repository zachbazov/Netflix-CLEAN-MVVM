//
//  MediaPlayerView.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var media: Media { get }
    var item: MediaPlayerViewItem? { get }
    var isPlaying: Bool { get }
}

private typealias ViewModelProtocol = ViewModelOutput

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

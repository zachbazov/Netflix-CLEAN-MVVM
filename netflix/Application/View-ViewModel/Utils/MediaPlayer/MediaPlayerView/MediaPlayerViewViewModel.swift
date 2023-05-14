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
}

// MARK: - MediaPlayerViewViewModel Type

struct MediaPlayerViewViewModel {
    let media: Media
    let item: MediaPlayerViewItem?
    
    init(with viewModel: DetailViewModel) {
        guard let media = viewModel.media else { fatalError() }
        
        self.media = media
        self.item = MediaPlayerViewItem(with: media)
    }
}

// MARK: - ViewModel Implementation

extension MediaPlayerViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension MediaPlayerViewViewModel: ViewModelProtocol {}

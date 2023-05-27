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
    let coordinator: DetailViewCoordinator
    
    let media: Media
    let item: MediaPlayerViewItem?
    
    init(with viewModel: DetailViewModel) {
        guard let coordinator = viewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        guard let media = viewModel.media else { fatalError() }
        
        self.media = media
        self.item = MediaPlayerViewItem(with: media)
    }
}

// MARK: - ViewModel Implementation

extension MediaPlayerViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension MediaPlayerViewViewModel: ViewModelProtocol {}

/*
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
     let coordinator: DetailViewCoordinator
     
     let media: Media
     let item: MediaPlayerViewItem?
     
     init(with viewModel: DetailViewModel) {
         guard let coordinator = viewModel.coordinator,
               let media = viewModel.media
         else { fatalError() }
         
         self.coordinator = coordinator
         self.media = media
         self.item = MediaPlayerViewItem(with: media)
     }
 }

 // MARK: - ViewModel Implementation

 extension MediaPlayerViewViewModel: ViewModel {}

 // MARK: - ViewModelProtocol Implementation

 extension MediaPlayerViewViewModel: ViewModelProtocol {}

 */

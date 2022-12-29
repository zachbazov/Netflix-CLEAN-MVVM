//
//  MediaPlayer.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import AVKit

// MARK: - MediaPlayerDelegate Protocol

protocol MediaPlayerDelegate: AnyObject {
    func playerDidPlay(_ mediaPlayer: MediaPlayer)
    func playerDidStop(_ mediaPlayer: MediaPlayer)
    func player(_ mediaPlayer: MediaPlayer, willReplaceItem item: AVPlayerItem?)
    func player(_ mediaPlayer: MediaPlayer, willVerifyUrl url: URL) -> Bool
}

// MARK: - MediaPlayer Type

struct MediaPlayer {
    
    // MARK: Properties
    
    let player = AVPlayer()
    let mediaPlayerLayer: MediaPlayerLayer
    
    // MARK: Initializer
    
    init(on parent: UIView) {
        self.mediaPlayerLayer = MediaPlayerLayer(frame: parent.bounds)
        parent.addSubview(self.mediaPlayerLayer)
        self.mediaPlayerLayer.constraintToSuperview(parent)
        self.mediaPlayerLayer.player = self.player
    }
}

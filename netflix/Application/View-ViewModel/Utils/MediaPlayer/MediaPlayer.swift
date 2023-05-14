//
//  MediaPlayer.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import AVKit

// MARK: - MediaPlayerDelegate Type

protocol MediaPlayerDelegate: AnyObject {
    func playerDidPlay(_ mediaPlayer: MediaPlayer)
    func playerDidStop(_ mediaPlayer: MediaPlayer)
    func player(_ mediaPlayer: MediaPlayer, willReplaceItem item: AVPlayerItem?)
    func player(_ mediaPlayer: MediaPlayer, canOpenURL url: URL) -> Bool
}

// MARK: - PlayerProtocol Type

private protocol PlayerProtocol {
    var layer: MediaPlayerLayer { get }
    var player: AVPlayer { get }
    
    func didLoad()
    func configurePlayer()
}

// MARK: - MediaPlayer Type

struct MediaPlayer {
    fileprivate let layer: MediaPlayerLayer
    
    let player = AVPlayer()
    
    init(on parent: UIView) {
        self.layer = MediaPlayerLayer(on: parent)
        
        didLoad()
    }
}

// MARK: - PlayerProtocol Implementation

extension MediaPlayer: PlayerProtocol {
    fileprivate func didLoad() {
        configurePlayer()
    }
    
    fileprivate func configurePlayer() {
        layer.setPlayer(player)
    }
}

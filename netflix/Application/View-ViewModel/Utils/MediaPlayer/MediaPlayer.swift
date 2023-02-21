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

private protocol PlayerOutput {
    var player: AVPlayer { get }
    var layer: MediaPlayerLayer { get }
}

private typealias PlayerProtocol = PlayerOutput

// MARK: - MediaPlayer Type

struct MediaPlayer {
    let player = AVPlayer()
    let layer: MediaPlayerLayer
    
    init(on parent: UIView) {
        self.layer = MediaPlayerLayer(frame: parent.bounds)
        parent.addSubview(self.layer)
        self.layer.constraintToSuperview(parent)
        self.layer.player = self.player
    }
}

// MARK: - PlayerProtocol Implementation

extension MediaPlayer: PlayerProtocol {}

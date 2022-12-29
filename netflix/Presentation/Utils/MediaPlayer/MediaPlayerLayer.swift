//
//  MediaPlayerLayer.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: - MediaPlayerLayer Type

final class MediaPlayerLayer: UIView {
    
    // MARK: Properties
    
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer! {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    // MARK: Deinitializer
    
    deinit { player = nil }
}

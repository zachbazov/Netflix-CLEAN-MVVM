//
//  MediaPlayerLayer.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: - LayerProtocol Type

private protocol LayerOutput {
    var playerLayer: AVPlayerLayer { get }
    var player: AVPlayer! { get }
}

private typealias LayerProtocol = LayerOutput

// MARK: - MediaPlayerLayer Type

final class MediaPlayerLayer: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer! {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    deinit { player = nil }
}

// MARK: - LayerProtocol Implementation

extension MediaPlayerLayer: LayerProtocol {}

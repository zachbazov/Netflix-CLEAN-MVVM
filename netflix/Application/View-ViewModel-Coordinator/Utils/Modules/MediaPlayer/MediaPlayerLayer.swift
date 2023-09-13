//
//  MediaPlayerLayer.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: - LayerProtocol Type

private protocol LayerProtocol {
    var playerLayer: AVPlayerLayer { get }
    var player: AVPlayer { get }
    
    func didLoad(on parent: UIView)
    func hierarchyWillConfigure(on parent: UIView)
    
    func setVideoGravity()
    func setPlayer(_ player: AVPlayer)
}

// MARK: - MediaPlayerLayer Type

final class MediaPlayerLayer: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    fileprivate var player: AVPlayer {
        get {
            guard let player = playerLayer.player else { fatalError() }
            return player
        }
        set { playerLayer.player = newValue }
    }
    
    init(on parent: UIView) {
        super.init(frame: .zero)
        
        self.didLoad(on: parent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - LayerProtocol Implementation

extension MediaPlayerLayer: LayerProtocol {
    fileprivate func didLoad(on parent: UIView) {
        hierarchyWillConfigure(on: parent)
        willConfigure()
    }
    
    fileprivate func hierarchyWillConfigure(on parent: UIView) {
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
    }
    
    fileprivate func willConfigure() {
        setVideoGravity()
    }
    
    fileprivate func setVideoGravity() {
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.player = player
    }
}

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
    var player: AVPlayer? { get }
    
    func didLoad()
    func hierarchyWillConfigure()
    func willDeallocate()
    func setVideoGravity()
    func setPlayer(_ player: AVPlayer)
}

// MARK: - MediaPlayerLayer Type

final class MediaPlayerLayer: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    private weak var parent: UIView?
    
    deinit {
        print("deinit \(Self.self)")
        
        willDeallocate()
    }
    
    init(on parent: UIView) {
        self.parent = parent
        
        super.init(frame: .zero)
        
        self.didLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - LayerProtocol Implementation

extension MediaPlayerLayer: LayerProtocol {
    fileprivate func didLoad() {
        hierarchyWillConfigure()
        configureLayer()
    }
    
    fileprivate func hierarchyWillConfigure() {
        guard let parent = parent else { return }
        
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
    }
    
    fileprivate func willDeallocate() {
        player = nil
        parent = nil
    }
    
    fileprivate func configureLayer() {
        setVideoGravity()
    }
    
    fileprivate func setVideoGravity() {
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.player = player
    }
}

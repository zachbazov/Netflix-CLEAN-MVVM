//
//  MediaPlayerView.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import AVKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    var prepareToPlay: ((Bool) -> Void)? { get }
}

private protocol ViewOutput {
    var mediaPlayer: MediaPlayer! { get }
    var overlayView: MediaPlayerOverlayView! { get }
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - MediaPlayerView Type

final class MediaPlayerView: View<MediaPlayerViewViewModel> {
    var mediaPlayer: MediaPlayer!
    var overlayView: MediaPlayerOverlayView!
    
    var prepareToPlay: ((Bool) -> Void)?
    
    weak var delegate: MediaPlayerDelegate?
    
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: parent.bounds)
        self.delegate = self
        self.viewModel = MediaPlayerViewViewModel(with: viewModel)
        self.mediaPlayer = MediaPlayer(on: self)
        self.overlayView = MediaPlayerOverlayView(on: self)
        self.addSubview(self.overlayView)
        self.viewDidTargetSubviews()
        self.overlayView.constraintToSuperview(self)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        mediaPlayer = nil
        overlayView = nil
        prepareToPlay = nil
        delegate = nil
    }
    
    override func viewDidConfigure() {
        mediaPlayer.layer.playerLayer.frame = mediaPlayer.layer.bounds
        mediaPlayer.layer.playerLayer.videoGravity = .resizeAspectFill
    }
    
    override func viewDidTargetSubviews() {
        let tapRecognizer = UITapGestureRecognizer(target: overlayView, action: #selector(overlayView.didSelect))
        addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidUnbindObservers() {
        if let timeObserverToken = overlayView?.configuration.observers.timeObserverToken {
            printIfDebug(.success, "Removed `MediaPlayerView` observers.")
            mediaPlayer?.player.removeTimeObserver(timeObserverToken)
        }
    }
}

// MARK: - ViewProtocol Implementation

extension MediaPlayerView: ViewProtocol {}

// MARK: - MediaPlayerDelegate Implementation

extension MediaPlayerView: MediaPlayerDelegate {
    func playerDidPlay(_ mediaPlayer: MediaPlayer) {
        viewModel.isPlaying = true
        prepareToPlay?(viewModel.isPlaying)
        mediaPlayer.player.play()
    }
    
    func playerDidStop(_ mediaPlayer: MediaPlayer) {
        viewModel.isPlaying = false
        mediaPlayer.player.replaceCurrentItem(with: nil)
    }
    
    func player(_ mediaPlayer: MediaPlayer,
                willReplaceItem item: AVPlayerItem? = nil) {
        mediaPlayer.player.replaceCurrentItem(with: item == nil ? viewModel.item : item!)
    }
    
    func player(_ mediaPlayer: MediaPlayer,
                canOpenURL url: URL) -> Bool { UIApplication.shared.canOpenURL(url) }
}

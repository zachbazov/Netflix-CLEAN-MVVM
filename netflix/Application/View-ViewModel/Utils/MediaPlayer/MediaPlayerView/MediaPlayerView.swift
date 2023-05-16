//
//  MediaPlayerView.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import AVKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var mediaPlayer: MediaPlayer? { get }
    var overlay: MediaPlayerOverlayView? { get }
    var delegate: MediaPlayerDelegate? { get }
    
    var prepareToPlay: ((Bool) -> Void)? { get }
    
    func createMediaPlayer()
    func createMediaPlayerOverlay()
}

// MARK: - MediaPlayerView Type

final class MediaPlayerView: View<MediaPlayerViewViewModel> {
    var mediaPlayer: MediaPlayer?
    var overlay: MediaPlayerOverlayView?
    
    weak var delegate: MediaPlayerDelegate?
    
    var prepareToPlay: ((Bool) -> Void)?
    
    init(with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        
        self.viewModel = MediaPlayerViewViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillTargetSubviews()
    }
    
    override func viewWillDeploySubviews() {
        createMediaPlayer()
        createMediaPlayerOverlay()
    }
    
    override func viewHierarchyWillConfigure() {
        guard let container = viewModel.coordinator.viewController?.previewContainer else { return }
        
        self.addToHierarchy(on: container)
            .constraintToSuperview(container)
        
        overlay?
            .addToHierarchy(on: self)
            .constraintToSuperview(self)
    }
    
    override func viewWillConfigure() {
        setMediaPlayerDelegate()
    }
    
    override func viewWillTargetSubviews() {
        let tapRecognizer = UITapGestureRecognizer(target: overlay, action: #selector(overlay?.didSelect))
        addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillUnbindObservers() {
        guard let observers = overlay?.observers else { return }
        
        mediaPlayer?.player.removeTimeObserver(observers.timeObserverToken as Any)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        mediaPlayer = nil
        overlay = nil
        prepareToPlay = nil
        delegate = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension MediaPlayerView: ViewProtocol {
    fileprivate func createMediaPlayer() {
        mediaPlayer = MediaPlayer(on: self)
    }
    
    fileprivate func createMediaPlayerOverlay() {
        overlay = MediaPlayerOverlayView(on: self)
    }
}

// MARK: - MediaPlayerDelegate Implementation

extension MediaPlayerView: MediaPlayerDelegate {
    func playerDidPlay(_ mediaPlayer: MediaPlayer) {
        prepareToPlay?(true)
        
        mediaPlayer.player.play()
    }
    
    func playerDidStop(_ mediaPlayer: MediaPlayer) {
        mediaPlayer.player.replaceCurrentItem(with: nil)
    }
    
    func player(_ mediaPlayer: MediaPlayer, willReplaceItem item: AVPlayerItem? = nil) {
        mediaPlayer.player.replaceCurrentItem(with: item == nil ? viewModel.item : item!)
    }
    
    func player(_ mediaPlayer: MediaPlayer, canOpenURL url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
}

// MARK: - Private Presentation Logic

extension MediaPlayerView {
    private func setMediaPlayerDelegate() {
        delegate = self
    }
}

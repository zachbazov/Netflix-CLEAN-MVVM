//
//  MediaPlayerOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: -  ViewProtocol Type

private protocol ViewProtocol {
    var observers: MediaPlayerObservers { get }
    var mediaPlayerView: MediaPlayerView? { get }
    
    func didSelect(view: Any)
    func valueDidChange(for slider: UISlider)
    func setTitle(_ title: String?)
}

// MARK: - MediaPlayerOverlayView Type

final class MediaPlayerOverlayView: UIView, View {
    @IBOutlet private(set) weak var airPlayButton: UIButton!
    @IBOutlet private weak var rotateButton: UIButton!
    @IBOutlet private(set) weak var backwardButton: UIButton!
    @IBOutlet private(set) weak var playButton: UIButton!
    @IBOutlet private(set) weak var forwardButton: UIButton!
    @IBOutlet private weak var muteButton: UIButton!
    @IBOutlet private(set) weak var progressView: UIProgressView!
    @IBOutlet private(set) weak var trackingSlider: UISlider!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var startTimeLabel: UILabel!
    @IBOutlet private(set) weak var durationLabel: UILabel!
    @IBOutlet private(set) weak var timeSeparatorLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    
    fileprivate(set) var observers = MediaPlayerObservers()
    
    fileprivate weak var mediaPlayerView: MediaPlayerView?
    
    var viewModel: MediaPlayerOverlayViewViewModel!
    
    init(on parent: MediaPlayerView) {
        super.init(frame: .zero)
        
        self.nibDidLoad()
        
        self.mediaPlayerView = parent
        
        self.viewModel = MediaPlayerOverlayViewViewModel()
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewWillConfigure()
        viewWillTargetSubviews()
        viewWillBindObservers()
        viewWillAppear()
    }
    
    func viewWillConfigure() {
        gradientView.setBackgroundColor(UIColor.black.withAlphaComponent(0.5))
        
        let title = mediaPlayerView?.viewModel?.media.title
        setTitle(title)
        
        if airPlayButton.isRoutePickerView {
            return
        } else {
            airPlayButton.toRoutePickerView()
        }
        
        configureButtonsForItemStatus()
    }
    
    func viewWillTargetSubviews() {
        targetButtons()
        targetSlider()
    }
    
    func viewWillAppear() {
        startTimer()
        
        progressView.isHidden(true)
        gradientView.isHidden(false)
        playButton.isHidden(false)
        backwardButton.isHidden(false)
        forwardButton.isHidden(false)
        rotateButton.isHidden(false)
        airPlayButton.isHidden(false)
        muteButton.isHidden(false)
        trackingSlider.isHidden(false)
        startTimeLabel.isHidden(false)
        durationLabel.isHidden(false)
        titleLabel.isHidden(false)
        timeSeparatorLabel.isHidden(false)
    }
    
    @objc
    func viewWillDisappear() {
        viewModel?.timer.invalidate()
        
        progressView.isHidden(false)
        gradientView.isHidden(true)
        playButton.isHidden(true)
        backwardButton.isHidden(true)
        forwardButton.isHidden(true)
        rotateButton.isHidden(true)
        airPlayButton.isHidden(true)
        muteButton.isHidden(true)
        trackingSlider.isHidden(true)
        startTimeLabel.isHidden(true)
        durationLabel.isHidden(true)
        titleLabel.isHidden(true)
        timeSeparatorLabel.isHidden(true)
    }
    
    func viewWillBindObservers() {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
        
        setTimeObserverTokenObserver(for: player)
        
        setPlayerItemDidEndPlayingObserver(player)
        setPlayerTimeControlStatusObserver(player)
        setPlayerItemFastForwardObserver(player)
        setPlayerItemReverseObserver(player)
        setPlayerItemFastReverseObserver(player)
        setPlayerItemStatusObserver(player)
    }
    
    func viewWillUnbindObservers() {
        observers.playerItemStatusObserver?.invalidate()
        observers.playerItemFastForwardObserver?.invalidate()
        observers.playerItemReverseObserver?.invalidate()
        observers.playerItemFastReverseObserver?.invalidate()
        observers.playerTimeControlStatusObserver?.invalidate()
        
        observers.cancelBag?.removeAll()
        
        observers.timeObserverToken = nil
        observers.playerItemStatusObserver = nil
        observers.playerItemFastForwardObserver = nil
        observers.playerItemReverseObserver = nil
        observers.playerItemFastReverseObserver = nil
        observers.playerTimeControlStatusObserver = nil
        observers.playerItemDidEndPlayingObserver = nil
        observers.cancelBag = nil
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        viewModel?.timer.invalidate()
        
        mediaPlayerView?.viewModel = nil
        mediaPlayerView = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension MediaPlayerOverlayView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension MediaPlayerOverlayView: ViewProtocol {
    @objc
    func didSelect(view: Any) {
        viewWillAppear()
        
        guard let view = view as? UIView,
              let item = MediaPlayerOverlayView.Item(rawValue: view.tag),
              let player = mediaPlayerView?.mediaPlayer?.player
        else { return }
        
        switch item {
        case .airPlay:
            player.allowsExternalPlayback = true
        case .rotate:
            let orientation = DeviceOrientation.shared
            orientation.rotate()
        case .backward:
            if player.currentItem?.currentTime() == .zero,
               let duration = player.currentItem?.duration {
                player.currentItem?.seek(to: duration, completionHandler: nil)
            }
            
            let time = CMTime(value: 15, timescale: 1)
            
            player.seek(to: player.currentTime() - time)
            
            let progress = Float(player.currentTime().seconds)
                / Float(player.currentItem?.duration.seconds ?? .zero) - 10.0
                / Float(player.currentItem?.duration.seconds ?? .zero)
            
            progressView.progress = progress
        case .play:
            player.timeControlStatus == .playing ? player.pause() : player.play()
        case .forward:
            if player.currentItem?.currentTime() == player.currentItem?.duration {
                player.currentItem?.seek(to: .zero, completionHandler: nil)
            }
            
            let time = CMTime(value: 15, timescale: 1)
            
            player.seek(to: player.currentTime() + time)
            
            let progress = Float(player.currentTime().seconds)
                / Float(player.currentItem?.duration.seconds ?? .zero) + 10.0
                / Float(player.currentItem?.duration.seconds ?? .zero)
            
            progressView?.progress = progress
        case .mute:
            printIfDebug(.debug, "\(item.rawValue)")
        }
    }
    
    @objc
    func valueDidChange(for slider: UISlider) {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
        
        let newTime = CMTime(seconds: Double(slider.value), preferredTimescale: 600)
        
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
        progressView.setProgress(progressView.progress + Float(newTime.seconds), animated: true)
    }
    
    fileprivate func setTitle(_ title: String?) {
        titleLabel.text = title ?? .toBlank()
    }
}

// MARK: - Private Presentation Logic

extension MediaPlayerOverlayView {
    private func configurePlayButton() {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
        
        var systemImage: UIImage
        
        switch player.timeControlStatus {
        case .playing:
            systemImage = UIImage(systemName: "pause")!
        case .paused,
                .waitingToPlayAtSpecifiedRate:
            systemImage = UIImage(systemName: "arrowtriangle.right.fill")!
        default:
            systemImage = UIImage(systemName: "pause")!
        }
        
        playButton.setImage(systemImage, for: .normal)
    }
    
    private func targetButtons() {
        let views = [airPlayButton,
                     rotateButton,
                     backwardButton,
                     playButton,
                     forwardButton,
                     muteButton]
        
        views.forEach {
            $0?.addTarget(self, action: #selector(didSelect(view:)), for: .touchUpInside)
        }
    }
    
    private func targetSlider() {
        trackingSlider.addTarget(self, action: #selector(valueDidChange(for:)), for: .valueChanged)
    }
    
    private func startTimer() {
        guard let viewModel = viewModel else { return }
        
        viewModel.timer.schedule(timeInterval: TimeInterval(viewModel.durationThreshold),
                                 target: self,
                                 selector: #selector(viewWillDisappear),
                                 repeats: viewModel.repeats)
    }
    
    private func configureButtonsForItemStatus() {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer?,
              let item = player.currentItem else {
            return
        }
        switch item.status {
        case .failed:
            playButton.isEnabled = false
            trackingSlider.isEnabled = false
            startTimeLabel.isEnabled = false
            durationLabel.isEnabled = false
        case .readyToPlay:
            let newDurationInSeconds = Float(item.duration.seconds)
            let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
            
            playButton.isEnabled = true
            trackingSlider.isEnabled = true
            startTimeLabel.isEnabled = true
            durationLabel.isEnabled = true
            
            progressView.setProgress(currentTime, animated: true)
            
            trackingSlider.maximumValue = newDurationInSeconds
            trackingSlider.value = currentTime
            startTimeLabel.text = viewModel.timeString(currentTime)
            durationLabel.text = viewModel.timeString(newDurationInSeconds)
        default:
            playButton.isEnabled = false
            trackingSlider.isEnabled = false
            startTimeLabel.isEnabled = false
            durationLabel.isEnabled = false
        }
    }
}

// MARK: - Observers Implementation

extension MediaPlayerOverlayView {
    private func setTimeObserverTokenObserver(for player: AVPlayer) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(value: 1, timescale: timeScale)
        
        observers.timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main) { [weak self] time in
                guard let self = self else { return }
                let timeElapsed = Float(time.seconds)
                let duration = Float(player.currentItem?.duration.seconds ?? .zero).rounded()
                self.progressView.progress = timeElapsed / duration
                self.trackingSlider.value = timeElapsed
                self.startTimeLabel.text = self.viewModel.timeString(timeElapsed)
        }
    }
    
    private func setPlayerItemDidEndPlayingObserver(_ player: AVPlayer) {
        observers.cancelBag = []
        
        observers.playerItemDidEndPlayingObserver = NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { _ in player.seek(to: CMTime.zero)
        }
        observers.playerItemDidEndPlayingObserver
            .store(in: &observers.cancelBag)
    }
    
    private func setPlayerTimeControlStatusObserver(_ player: AVPlayer) {
        observers.playerTimeControlStatusObserver = player.observe(
            \AVPlayer.timeControlStatus,
             options: [.initial, .new],
             changeHandler: { [weak self] _, _ in
                 self?.configurePlayButton()
             })
    }
    
    private func setPlayerItemFastForwardObserver(_ player: AVPlayer) {
        observers.playerItemFastForwardObserver = player.observe(
            \AVPlayer.currentItem?.canPlayFastForward,
             options: [.initial, .new],
             changeHandler: { [weak self] player, _ in
                 self?.forwardButton.isEnabled = player.currentItem?.canPlayFastForward ?? false
             })
    }
    
    private func setPlayerItemReverseObserver(_ player: AVPlayer) {
        observers.playerItemReverseObserver = player.observe(
            \AVPlayer.currentItem?.canPlayReverse,
             options: [.initial],
             changeHandler: { [weak self] player, _ in
                 self?.backwardButton.isEnabled = player.currentItem?.canPlayReverse ?? false
             })
    }
    
    private func setPlayerItemFastReverseObserver(_ player: AVPlayer) {
        observers.playerItemFastReverseObserver = player.observe(
            \AVPlayer.currentItem?.canPlayFastReverse,
             options: [.initial, .new],
             changeHandler: { [weak self] player, _ in
                 self?.backwardButton.isEnabled = player.currentItem?.canPlayFastReverse ?? false
             })
    }
    
    private func setPlayerItemStatusObserver(_ player: AVPlayer) {
        observers.playerItemStatusObserver = player.observe(
            \AVPlayer.currentItem?.status,
             options: [.initial, .new],
             changeHandler: { [weak self] _, _ in
                 self?.viewWillConfigure()
             })
    }
}

// MARK: - Item Type

extension MediaPlayerOverlayView {
    /// Overlay Item representation type.
    fileprivate enum Item: Int {
        case airPlay
        case rotate
        case backward
        case play
        case forward
        case mute
    }
}

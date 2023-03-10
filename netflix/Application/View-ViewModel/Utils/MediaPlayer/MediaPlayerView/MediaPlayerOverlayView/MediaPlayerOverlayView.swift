//
//  MediaPlayerOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: - ConfigurationProtocol Type

private protocol ConfigurationInput {
    func startTimer(target: Any, selector: Selector)
    func viewDidTap(_ view: UIButton)
}

private protocol ConfigurationOutput {
    var durationThreshold: CGFloat! { get }
    var repeats: Bool! { get }
    var mediaPlayerView: MediaPlayerView! { get }
    var overlayView: MediaPlayerOverlayView! { get }
    var observers: MediaPlayerObservers { get }
    var timer: ScheduledTimer { get }
    
    func viewDidConfigure()
    func setupPlayButton()
    func viewDidBindObservers()
    func viewDidUnbindObservers()
}

private typealias ConfigurationProtocol = ConfigurationInput & ConfigurationOutput

// MARK: - MediaPlayerOverlayViewConfiguration Type

final class MediaPlayerOverlayViewConfiguration {
    fileprivate var durationThreshold: CGFloat!
    fileprivate var repeats: Bool!
    fileprivate weak var mediaPlayerView: MediaPlayerView!
    fileprivate weak var overlayView: MediaPlayerOverlayView!
    fileprivate(set) var observers = MediaPlayerObservers()
    fileprivate var timer = ScheduledTimer()
    
    init(durationThreshold: CGFloat? = 3.0, repeats: Bool? = true) {
        self.durationThreshold = durationThreshold
        self.repeats = repeats
    }
    
    deinit {
        viewDidUnbindObservers()
        timer.invalidate()
        mediaPlayerView = nil
        overlayView = nil
        durationThreshold = nil
        repeats = nil
    }
}

// MARK: - ConfigurationProtocol Implementation

extension MediaPlayerOverlayViewConfiguration: ConfigurationProtocol {
    func viewDidConfigure() {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer?,
              let overlayView = overlayView,
              let item = player.currentItem else {
            return
        }
        switch item.status {
        case .failed:
            overlayView.playButton.isEnabled = false
            overlayView.trackingSlider.isEnabled = false
            overlayView.startTimeLabel.isEnabled = false
            overlayView.durationLabel.isEnabled = false
        case .readyToPlay:
            overlayView.playButton.isEnabled = true
            let newDurationInSeconds = Float(item.duration.seconds)
            let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
            overlayView.trackingSlider.isEnabled = true
            overlayView.startTimeLabel.isEnabled = true
            overlayView.durationLabel.isEnabled = true
            
            overlayView.progressView.setProgress(currentTime, animated: true)
            overlayView.trackingSlider.maximumValue = newDurationInSeconds
            overlayView.trackingSlider.value = currentTime
            overlayView.startTimeLabel.text = overlayView.viewModel.timeString(currentTime)
            overlayView.durationLabel.text = overlayView.viewModel.timeString(newDurationInSeconds)
        default:
            overlayView.playButton.isEnabled = false
            overlayView.trackingSlider.isEnabled = false
            overlayView.startTimeLabel.isEnabled = false
            overlayView.durationLabel.isEnabled = false
        }
    }
    
    func setupPlayButton() {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
        
        var systemImage: UIImage
        switch player.timeControlStatus {
        case .playing:
            systemImage = .init(systemName: "pause")!
        case .paused,
                .waitingToPlayAtSpecifiedRate:
            systemImage = .init(systemName: "arrowtriangle.right.fill")!
        default:
            systemImage = .init(systemName: "pause")!
        }
        
        guard let image = systemImage as UIImage? else { return }
        mainQueueDispatch { [weak self] in
            self?.overlayView.playButton.setImage(image, for: .normal)
        }
    }
    
    func startTimer(target: Any, selector: Selector) {
        timer.schedule(timeInterval: overlayView.configuration.durationThreshold,
                       target: target,
                       selector: selector,
                       repeats: overlayView.configuration.repeats)
    }
    
    func viewDidTap(_ view: UIButton) {
        guard let item = MediaPlayerOverlayView.Item(rawValue: view.tag) else { return }
        switch item {
        case .airPlay:
            if let player = mediaPlayerView.mediaPlayer.player as AVPlayer? {
                player.allowsExternalPlayback = true
            }
        case .rotate:
            let orientation = DeviceOrientation.shared
            orientation.rotate()
        case .backward:
            if mediaPlayerView?.mediaPlayer?.player.currentItem?.currentTime() == .zero {
                if let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer?,
                   let duration = player.currentItem?.duration {
                    player.currentItem?.seek(to: duration, completionHandler: nil)
                }
            }
            let time = CMTime(value: 15, timescale: 1)
            DispatchQueue.main.async { [weak self] in
                guard
                    let self = self,
                    let player = self.mediaPlayerView?.mediaPlayer?.player as AVPlayer?
                else { return }
                player.seek(to: player.currentTime() - time)
                let progress = Float(player.currentTime().seconds)
                    / Float(player.currentItem?.duration.seconds ?? .zero) - 10.0
                    / Float(player.currentItem?.duration.seconds ?? .zero)
                self.overlayView.progressView.progress = progress
            }
        case .play:
            guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
            player.timeControlStatus == .playing ? player.pause() : player.play()
        case .forward:
            guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
            if player.currentItem?.currentTime() == player.currentItem?.duration {
                player.currentItem?.seek(to: .zero, completionHandler: nil)
            }
            let time = CMTime(value: 15, timescale: 1)
            player.seek(to: player.currentTime() + time)
            let progress = Float(player.currentTime().seconds)
                / Float(player.currentItem?.duration.seconds ?? .zero) + 10.0
                / Float(player.currentItem?.duration.seconds ?? .zero)
            self.overlayView?.progressView?.progress = progress
        case .mute:
            printIfDebug(.debug, "\(item.rawValue)")
        }
    }
    
    fileprivate func viewDidBindObservers() {
        guard let player = mediaPlayerView.mediaPlayer.player as AVPlayer? else { return }
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(value: 1, timescale: timeScale)
        observers.timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main) { [weak self] time in
                guard let self = self else { return }
                let timeElapsed = Float(time.seconds)
                let duration = Float(player.currentItem?.duration.seconds ?? .zero).rounded()
                self.overlayView.progressView.progress = timeElapsed / duration
                self.overlayView.trackingSlider.value = timeElapsed
                self.overlayView.startTimeLabel.text = self.overlayView.viewModel.timeString(timeElapsed)
        }
        
        observers.cancelBag = []
        
        observers.playerItemDidEndPlayingObserver = NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { _ in player.seek(to: CMTime.zero)
        }
        observers.playerItemDidEndPlayingObserver.store(in: &observers.cancelBag)
        
        observers.playerTimeControlStatusObserver = player.observe(
            \AVPlayer.timeControlStatus,
             options: [.initial, .new],
             changeHandler: { [weak self] _, _ in self?.setupPlayButton() })
        
        observers.playerItemFastForwardObserver = player.observe(
            \AVPlayer.currentItem?.canPlayFastForward,
             options: [.initial, .new],
             changeHandler: { [weak self] player, _ in
                 self?.overlayView.forwardButton.isEnabled = player.currentItem?.canPlayFastForward ?? false
             })
        
        observers.playerItemReverseObserver = player.observe(
            \AVPlayer.currentItem?.canPlayReverse,
             options: [.initial],
             changeHandler: { [weak self] player, _ in
                 self?.overlayView.backwardButton.isEnabled = player.currentItem?.canPlayReverse ?? false
             })
        
        observers.playerItemFastReverseObserver = player.observe(
            \AVPlayer.currentItem?.canPlayFastReverse,
             options: [.initial, .new],
             changeHandler: { [weak self] player, _ in
                 self?.overlayView.backwardButton.isEnabled = player.currentItem?.canPlayFastReverse ?? false
             })
        
        observers.playerItemStatusObserver = player.observe(
            \AVPlayer.currentItem?.status,
             options: [.initial, .new],
             changeHandler: { [weak self] _, _ in
                 self?.viewDidConfigure()
             })
    }
    
    func viewDidUnbindObservers() {
        printIfDebug(.success, "Removed `MediaPlayerOverlayView` observers.")
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
    }
}

// MARK: -  ViewProtocol Type

private protocol ViewInput {
    func valueDidChange(for slider: UISlider)
    func didSelect(view: Any)
    func didTarget(_ views: UIButton...)
}

private protocol ViewOutput {
    var configuration: MediaPlayerOverlayViewConfiguration! { get }
    var mediaPlayerView: MediaPlayerView! { get }
    var mediaPlayerViewModel: MediaPlayerViewViewModel! { get }
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - MediaPlayerOverlayView Type

final class MediaPlayerOverlayView: View<MediaPlayerOverlayViewViewModel>, ViewInstantiable {
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
    
    private(set) var configuration: MediaPlayerOverlayViewConfiguration!
    fileprivate weak var mediaPlayerView: MediaPlayerView!
    fileprivate var mediaPlayerViewModel: MediaPlayerViewViewModel!
    
    init(on parent: MediaPlayerView) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.mediaPlayerView = parent
        self.mediaPlayerViewModel = parent.viewModel
        self.viewModel = MediaPlayerOverlayViewViewModel()
        self.configuration = MediaPlayerOverlayViewConfiguration()
        self.configuration.overlayView = self
        self.configuration.mediaPlayerView = parent
        self.configuration.viewDidBindObservers()
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        mediaPlayerView = nil
        mediaPlayerViewModel = nil
        viewModel = nil
        configuration = nil
    }
    
    override func viewDidLoad() {
        viewDidConfigure()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewWillAppear()
    }
    
    override func viewDidDeploySubviews() {
        airPlayButton.asRoutePickerView()
    }
    
    override func viewDidConfigure() {
        gradientView.backgroundColor = .black.withAlphaComponent(0.5)
        
        titleLabel.text = mediaPlayerViewModel.media.title
    }
    
    override func viewDidTargetSubviews() {
        didTarget(airPlayButton,
                  rotateButton,
                  backwardButton,
                  playButton,
                  forwardButton,
                  muteButton)
        
        trackingSlider.addTarget(self,
                                 action: #selector(valueDidChange(for:)),
                                 for: .valueChanged)
    }
    
    override func viewWillAppear() {
        configuration.startTimer(target: self, selector: #selector(viewWillDisappear))
        
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
    override func viewWillDisappear() {
        configuration.timer.invalidate()
        
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
}

// MARK: - ViewProtocol Type

extension MediaPlayerOverlayView: ViewProtocol {
    @objc
    func didSelect(view: Any) {
        viewWillAppear()
        guard let view = view as? UIView else { return }
        if case let view as UIButton = view { configuration.viewDidTap(view) }
    }
    
    @objc
    func valueDidChange(for slider: UISlider) {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
        let newTime = CMTime(seconds: Double(slider.value), preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        progressView.setProgress(progressView.progress + Float(newTime.seconds), animated: true)
    }
    
    fileprivate func didTarget(_ views: UIButton...) {
        views.forEach { $0.addTarget(self,
                                     action: #selector(didSelect(view:)),
                                     for: .touchUpInside) }
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

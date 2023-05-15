//
//  MediaPlayerOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: -  ViewProtocol Type

private protocol ViewProtocol {
    var mediaPlayerView: MediaPlayerView! { get }
    var observers: MediaPlayerObservers { get }
    
    func configurePlayButton()
    func viewDidTap(_ view: UIButton)
    func valueDidChange(for slider: UISlider)
    func didSelect(view: Any)
}

// MARK: - MediaPlayerOverlayView Type

final class MediaPlayerOverlayView: View<MediaPlayerOverlayViewViewModel> {
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
    
    fileprivate weak var mediaPlayerView: MediaPlayerView!
    fileprivate(set) var observers = MediaPlayerObservers()
    
    init(on parent: MediaPlayerView) {
        super.init(frame: parent.bounds)
        
        self.nibDidLoad()
        
        self.mediaPlayerView = parent
        
        self.viewModel = MediaPlayerOverlayViewViewModel()
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewWillConfigure()
        viewWillTargetSubviews()
        viewWillBindObservers()
        viewWillAppear()
    }
    
    override func viewWillDeploySubviews() {
        airPlayButton.asRoutePickerView()
    }
    
    override func viewWillTargetSubviews() {
        targetButtons()
        targetSlider()
    }
    
    override func viewWillAppear() {
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
    override func viewWillDisappear() {
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
    
    override func viewWillBindObservers() {
        guard let player = mediaPlayerView.mediaPlayer?.player as AVPlayer? else { return }
        
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
        
        observers.cancelBag = []
        
        observers.playerItemDidEndPlayingObserver = NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { _ in player.seek(to: CMTime.zero)
        }
        observers.playerItemDidEndPlayingObserver
            .store(in: &observers.cancelBag)
        
        observers.playerTimeControlStatusObserver = player.observe(
            \AVPlayer.timeControlStatus,
             options: [.initial, .new],
             changeHandler: { [weak self] _, _ in
                 self?.configurePlayButton()
             })
        
        observers.playerItemFastForwardObserver = player.observe(
            \AVPlayer.currentItem?.canPlayFastForward,
             options: [.initial, .new],
             changeHandler: { [weak self] player, _ in
                 self?.forwardButton.isEnabled = player.currentItem?.canPlayFastForward ?? false
             })
        
        observers.playerItemReverseObserver = player.observe(
            \AVPlayer.currentItem?.canPlayReverse,
             options: [.initial],
             changeHandler: { [weak self] player, _ in
                 self?.backwardButton.isEnabled = player.currentItem?.canPlayReverse ?? false
             })
        
        observers.playerItemFastReverseObserver = player.observe(
            \AVPlayer.currentItem?.canPlayFastReverse,
             options: [.initial, .new],
             changeHandler: { [weak self] player, _ in
                 self?.backwardButton.isEnabled = player.currentItem?.canPlayFastReverse ?? false
             })
        
        observers.playerItemStatusObserver = player.observe(
            \AVPlayer.currentItem?.status,
             options: [.initial, .new],
             changeHandler: { [weak self] _, _ in
                 self?.viewWillConfigure()
             })
    }
    
    override func viewWillUnbindObservers() {
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
    
    override func viewWillConfigure() {
        gradientView.setBackgroundColor(.black.withAlphaComponent(0.5))
        
        titleLabel.text = mediaPlayerView?.viewModel?.media.title
        
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
            playButton.isEnabled = true
            let newDurationInSeconds = Float(item.duration.seconds)
            let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
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
    
    override func viewWillDeallocate() {
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
        
        guard let view = view as? UIView else { return }
        
        if case let view as UIButton = view { viewDidTap(view) }
    }
    
    @objc
    func valueDidChange(for slider: UISlider) {
        guard let player = mediaPlayerView?.mediaPlayer?.player as AVPlayer? else { return }
        
        let newTime = CMTime(seconds: Double(slider.value), preferredTimescale: 600)
        
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
        progressView.setProgress(progressView.progress + Float(newTime.seconds), animated: true)
    }
    
    fileprivate func configurePlayButton() {
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
            self?.playButton.setImage(image, for: .normal)
        }
    }
    
    func viewDidTap(_ view: UIButton) {
        guard let item = MediaPlayerOverlayView.Item(rawValue: view.tag) else { return }
        
        switch item {
        case .airPlay:
            if let player = mediaPlayerView.mediaPlayer?.player as AVPlayer? {
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
                self.progressView.progress = progress
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
            
            self.progressView?.progress = progress
        case .mute:
            printIfDebug(.debug, "\(item.rawValue)")
        }
    }
}

// MARK: - Private Presentation Logic

extension MediaPlayerOverlayView {
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
        
        viewModel.timer.schedule(timeInterval: viewModel.durationThreshold,
                                 target: self,
                                 selector: #selector(viewWillDisappear),
                                 repeats: viewModel.repeats)
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

/*
 //
 //  MediaPlayerOverlayView.swift
 //  netflix
 //
 //  Created by Zach Bazov on 06/10/2022.
 //

 import AVKit

 // MARK: -  ViewProtocol Type

 private protocol ViewProtocol {
 //    var mediaPlayerView: MediaPlayerView! { get }
 //    var mediaPlayerViewModel: MediaPlayerViewViewModel! { get }
     var observers: MediaPlayerObservers { get }
     
     func configurePlayButton()
     func viewDidTap(_ view: UIButton)
     func valueDidChange(for slider: UISlider)
     func didSelect(view: Any)
 }

 // MARK: - MediaPlayerOverlayView Type

 final class MediaPlayerOverlayView: View<MediaPlayerOverlayViewViewModel> {
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
     
 //    fileprivate weak var mediaPlayerView: MediaPlayerView!
 //    fileprivate var mediaPlayerViewModel: MediaPlayerViewViewModel!
     fileprivate(set) var observers = MediaPlayerObservers()
     
     init(on parent: UIView, with viewModel: MediaPlayerViewViewModel) {
         super.init(frame: parent.bounds)
         
         self.nibDidLoad()
         
 //        self.mediaPlayerViewModel = viewModel
         
         self.viewModel = MediaPlayerOverlayViewViewModel(with: viewModel)
         
         self.viewDidLoad()
     }
     
     required init?(coder: NSCoder) { fatalError() }
     
     deinit {
         print("deinit \(Self.self)")
         
         viewWillUnbindObservers()
         
         viewModel?.timer.invalidate()
         
 //        mediaPlayerView = nil
 //        mediaPlayerViewModel = nil
         viewModel = nil
     }
     
     override func viewDidLoad() {
         viewWillDeploySubviews()
         viewWillConfigure()
         viewWillTargetSubviews()
         viewWillBindObservers()
         viewWillAppear()
     }
     
     override func viewWillDeploySubviews() {
         airPlayButton.asRoutePickerView()
     }
     
     override func viewWillTargetSubviews() {
         targetButtons()
         targetSlider()
     }
     
     override func viewWillAppear() {
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
     override func viewWillDisappear() {
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
     
     override func viewWillBindObservers() {
         guard let controller = viewModel?.coordinator.viewController,
               let mediaPlayer = controller.previewView?.mediaPlayerView?.mediaPlayer
         else { return }
         
         let player = mediaPlayer.player
         
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
         
         observers.cancelBag = []
         
         observers.playerItemDidEndPlayingObserver = NotificationCenter.default
             .publisher(for: .AVPlayerItemDidPlayToEndTime)
             .sink { _ in player.seek(to: CMTime.zero)
         }
         observers.playerItemDidEndPlayingObserver
             .store(in: &observers.cancelBag)
         
         observers.playerTimeControlStatusObserver = player.observe(
             \AVPlayer.timeControlStatus,
              options: [.initial, .new],
              changeHandler: { [weak self] _, _ in
                  self?.configurePlayButton()
              })
         
         observers.playerItemFastForwardObserver = player.observe(
             \AVPlayer.currentItem?.canPlayFastForward,
              options: [.initial, .new],
              changeHandler: { [weak self] player, _ in
                  self?.forwardButton.isEnabled = player.currentItem?.canPlayFastForward ?? false
              })
         
         observers.playerItemReverseObserver = player.observe(
             \AVPlayer.currentItem?.canPlayReverse,
              options: [.initial],
              changeHandler: { [weak self] player, _ in
                  self?.backwardButton.isEnabled = player.currentItem?.canPlayReverse ?? false
              })
         
         observers.playerItemFastReverseObserver = player.observe(
             \AVPlayer.currentItem?.canPlayFastReverse,
              options: [.initial, .new],
              changeHandler: { [weak self] player, _ in
                  self?.backwardButton.isEnabled = player.currentItem?.canPlayFastReverse ?? false
              })
         
         observers.playerItemStatusObserver = player.observe(
             \AVPlayer.currentItem?.status,
              options: [.initial, .new],
              changeHandler: { [weak self] _, _ in
                  self?.viewWillConfigure()
              })
     }
     
     override func viewWillUnbindObservers() {
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
     
     override func viewWillConfigure() {
         gradientView.setBackgroundColor(.black.withAlphaComponent(0.5))
         
         titleLabel.text = viewModel.media.title
         
         guard let controller = viewModel?.coordinator.viewController,
               let mediaPlayer = controller.previewView?.mediaPlayerView?.mediaPlayer
         else { return }
         
         let player = mediaPlayer.player
         
         let item = player.currentItem
         
         switch item?.status {
         case .failed:
             playButton.isEnabled = false
             trackingSlider.isEnabled = false
             startTimeLabel.isEnabled = false
             durationLabel.isEnabled = false
         case .readyToPlay:
             playButton.isEnabled = true
             
             let newDurationInSeconds = Float(item?.duration.seconds ?? .zero)
             let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
             
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

 // MARK: - ViewInstantiable Implementation

 extension MediaPlayerOverlayView: ViewInstantiable {}

 // MARK: - ViewProtocol Implementation

 extension MediaPlayerOverlayView: ViewProtocol {
     @objc
     func didSelect(view: Any) {
         viewWillAppear()
         
         guard let view = view as? UIView else { return }
         
         if case let view as UIButton = view { viewDidTap(view) }
     }
     
     @objc
     func valueDidChange(for slider: UISlider) {
         guard let controller = viewModel?.coordinator.viewController,
               let mediaPlayer = controller.previewView?.mediaPlayerView?.mediaPlayer
         else { print(1);return }
         
         let player = mediaPlayer.player
         
         let newTime = CMTime(seconds: Double(slider.value), preferredTimescale: 600)
         
         player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
         print(22)
         progressView.setProgress(progressView.progress + Float(newTime.seconds), animated: true)
     }
     
     fileprivate func configurePlayButton() {
         guard let controller = viewModel?.coordinator.viewController,
               let mediaPlayer = controller.previewView?.mediaPlayerView?.mediaPlayer
         else { return }
         
         let player = mediaPlayer.player
         
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
             self?.playButton.setImage(image, for: .normal)
         }
     }
     
     func viewDidTap(_ view: UIButton) {
         guard let controller = viewModel?.coordinator.viewController,
               let mediaPlayer = controller.previewView?.mediaPlayerView?.mediaPlayer
         else { return }
         
         let player = mediaPlayer.player
         
         guard let item = MediaPlayerOverlayView.Item(rawValue: view.tag) else { return }
         
         switch item {
         case .airPlay:
             player.allowsExternalPlayback = true
         case .rotate:
             let orientation = DeviceOrientation.shared
             orientation.rotate()
         case .backward:
             if player.currentItem?.currentTime() == .zero {
                 if let duration = player.currentItem?.duration {
                     player.currentItem?.seek(to: duration, completionHandler: nil)
                 }
             }
             
             let time = CMTime(value: 15, timescale: 1)
             
             DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                 
                 player.seek(to: player.currentTime() - time)
                 
                 let progress = Float(player.currentTime().seconds)
                     / Float(player.currentItem?.duration.seconds ?? .zero) - 10.0
                     / Float(player.currentItem?.duration.seconds ?? .zero)
                 
                 self.progressView.progress = progress
             }
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
             
             self.progressView?.progress = progress
         case .mute:
             printIfDebug(.debug, "\(item.rawValue)")
         }
     }
 }

 // MARK: - Private Presentation Logic

 extension MediaPlayerOverlayView {
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
         
         viewModel.timer.schedule(timeInterval: viewModel.durationThreshold,
                                  target: self,
                                  selector: #selector(viewWillDisappear),
                                  repeats: viewModel.repeats)
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

 */

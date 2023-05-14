//
//  PreviewView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var mediaPlayerView: MediaPlayerView? { get }
    var imageView: UIImageView { get }
    
    func createImageView() -> UIImageView
    func createMediaPlayer(on parent: UIView,
                           view: PreviewView,
                           with viewModel: DetailViewModel) -> MediaPlayerView
}

// MARK: - PreviewView Type

final class PreviewView: View<PreviewViewViewModel> {
    private(set) var mediaPlayerView: MediaPlayerView?
    private(set) lazy var imageView = createImageView()
    
    private weak var parent: UIView?
    private weak var detailViewModel: DetailViewModel?
    
    /// Create a preview view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        self.parent = parent
        self.detailViewModel = viewModel
        
        super.init(frame: .zero)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillDeploySubviews()
        dataWillLoad()
    }
    
    override func viewHierarchyWillConfigure() {
        self.addToHierarchy(on: parent!)
            .constraintToSuperview(parent!)
    }
    
    override func viewWillDeploySubviews() {
        viewModel = PreviewViewViewModel(with: detailViewModel!.media!)
        mediaPlayerView = createMediaPlayer(on: parent!, view: self, with: detailViewModel!)
    }
    
    override func dataWillLoad() {
        loadResources()
    }
    
    override func viewWillDeallocate() {
        mediaPlayerView = nil
        
        viewModel = nil
    }
    
    func loadResources() {
        AsyncImageService.shared.load(
            url: viewModel.url,
            identifier: viewModel.identifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setImage(image)
                }
            }
    }
    
    func setImage(_ image: UIImage) {
        self.imageView.image = image
    }
}

// MARK: - ViewProtocol Implementation

extension PreviewView: ViewProtocol {
    fileprivate func createImageView() -> UIImageView {
        let imageView = UIImageView(frame: bounds)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        return imageView
    }
    
    fileprivate func createMediaPlayer(on parent: UIView,
                                       view: PreviewView,
                                       with viewModel: DetailViewModel) -> MediaPlayerView {
        let mediaPlayerView = MediaPlayerView(on: view, with: viewModel)
        
        mediaPlayerView.prepareToPlay = { [weak self] isPlaying in
            isPlaying ? self?.imageView.isHidden(true) : self?.imageView.isHidden(false)
        }
        
        mediaPlayerView.delegate?.player(mediaPlayerView.mediaPlayer,
                                         willReplaceItem: mediaPlayerView.viewModel.item)
        mediaPlayerView.delegate?.playerDidPlay(mediaPlayerView.mediaPlayer)
        
        parent.addSubview(mediaPlayerView)
        mediaPlayerView.constraintToSuperview(parent)
        
        return mediaPlayerView
    }
}

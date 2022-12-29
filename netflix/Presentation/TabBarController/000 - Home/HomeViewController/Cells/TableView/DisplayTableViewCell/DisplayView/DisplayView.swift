//
//  DisplayView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - DisplayView Type

final class DisplayView: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    // MARK: Type's Properties
    
    private var viewModel: DisplayViewViewModel!
    private(set) var panelView: PanelView!
    
    // MARK: Initializer
    
    /// Create a display view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: DisplayTableViewCellViewModel) {
        super.init(frame: .zero)
        self.nibDidLoad()
        let homeViewModel = viewModel.coordinator!.viewController!.viewModel!
        let mediaFromCache = mediaFromCache(with: homeViewModel)
        self.viewModel = DisplayViewViewModel(with: mediaFromCache)
        self.panelView = PanelView(on: panelViewContainer, with: viewModel)
        self.viewDidLoad()
        self.viewDidConfigure(with: self.viewModel)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension DisplayView {
    private func viewDidLoad() {
        setupSubviews()
    }
    
    private func setupSubviews() {
        setupGradientView()
    }
    
    private func setupGradientView() {
        bottomGradientView.addGradientLayer(
            frame: bottomGradientView.bounds,
            colors: [.clear, .black],
            locations: [0.0, 0.66])
        
        posterImageView.contentMode = .scaleAspectFill
    }
    /// Configure the view.
    /// - Parameter viewModel: Coordinating view model.
    private func viewDidConfigure(with viewModel: DisplayViewViewModel) {
        posterImageView.image = nil
        logoImageView.image = nil
        genresLabel.attributedText = nil
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                asynchrony { self?.posterImageView.image = image }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                asynchrony { self?.logoImageView.image = image }
            }
        
        genresLabel.attributedText = viewModel.attributedGenres
    }
}

// MARK: - Private Methods

extension DisplayView {
    /// Retrieve a media object from the display cache.
    /// - Parameter viewModel: Coordinating view model.
    /// - Returns: A media object.
    private func mediaFromCache(with viewModel: HomeViewModel) -> Media {
        if case .all = viewModel.dataSourceState.value { return viewModel.displayMediaCache[.all]! }
        else if case .series = viewModel.dataSourceState.value { return viewModel.displayMediaCache[.series]! }
        else { return viewModel.displayMediaCache[.films]! }
    }
}

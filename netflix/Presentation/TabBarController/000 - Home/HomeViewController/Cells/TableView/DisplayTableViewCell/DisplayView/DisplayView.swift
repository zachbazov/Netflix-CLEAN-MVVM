//
//  DisplayView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

struct DisplayViewConfiguration {
    weak var view: DisplayView?
    
    init(view: DisplayView, viewModel: DisplayViewViewModel) {
        self.view = view
        self.viewDidConfigure(with: viewModel)
    }
    
    func viewDidConfigure(with viewModel: DisplayViewViewModel) {
        view?.posterImageView.image = nil
        view?.logoImageView.image = nil
        view?.genresLabel.attributedText = nil
        
        AsyncImageFetcher.shared.load(
            in: .home,
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { image in
                asynchrony { view?.posterImageView.image = image }
            }
        
        AsyncImageFetcher.shared.load(
            in: .home,
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { image in
                asynchrony { view?.logoImageView.image = image }
            }
        
        view?.genresLabel.attributedText = viewModel.attributedGenres
    }
}

final class DisplayView: UIView, ViewInstantiable {
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    private var viewModel: DisplayViewViewModel!
    private var configuration: DisplayViewConfiguration!
    var panelView: PanelView!
    
    init(with viewModel: DisplayTableViewCellViewModel) {
        super.init(frame: .zero)
        self.nibDidLoad()
        viewModel.presentedDisplayMediaDidChange()
        self.viewModel = DisplayViewViewModel(with: viewModel.presentedMedia.value!)
        self.panelView = PanelView(on: panelViewContainer, with: viewModel)
        self.configuration = DisplayViewConfiguration(view: self, viewModel: self.viewModel)
        self.viewDidLoad()
    }
    
    deinit {
        configuration = nil
        viewModel = nil
        panelView.removeFromSuperview()
        panelView = nil
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
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
}

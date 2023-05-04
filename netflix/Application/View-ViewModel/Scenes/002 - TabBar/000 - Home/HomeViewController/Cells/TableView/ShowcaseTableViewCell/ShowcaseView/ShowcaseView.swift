//
//  ShowcaseView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var panelView: PanelView! { get }
}

// MARK: - ShowcaseView Type

final class ShowcaseView: View<ShowcaseViewViewModel> {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    private(set) var panelView: PanelView!
    private(set) var gradient: GradientView?
    
    init(with viewModel: ShowcaseTableViewCellViewModel?) {
        super.init(frame: .zero)
        self.nibDidLoad()
        let homeViewModel = viewModel?.coordinator?.viewController?.viewModel
        let state = homeViewModel?.dataSourceState.value ?? .all
        let media = homeViewModel?.showcases[state]
        self.viewModel = ShowcaseViewViewModel(media: media, with: homeViewModel)
        self.panelView = PanelView(on: panelViewContainer, with: viewModel)
        self.viewDidDeploySubviews()
        self.contentView.constraintToSuperview(self)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        viewDidDeallocate()
        panelView = nil
        gradient = nil
    }
    
    override func viewDidDeploySubviews() {
        guard let viewModel = viewModel else { return }
        
        setDarkBottomGradient()
        setBackgroundColor()
        setPosterStroke()
        setGenres(attributed: viewModel.attributedGenres)
        setMediaType()
        setGestures()
        
        loadResources()
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
        logoImageView.image = nil
        genresLabel.attributedText = nil
    }
    
    override func viewDidDeallocate() {
        panelView?.viewDidUnbindObservers()
        panelView?.removeFromSuperview()
        
        gradient?.removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension ShowcaseView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension ShowcaseView: ViewProtocol {
    @objc func didTap() {
        guard let controller = viewModel.coordinator?.viewController else { return }
        let homeViewModel = controller.viewModel
        let state = homeViewModel?.dataSourceState.value ?? .all
        let coordinator = homeViewModel!.coordinator!
        let section = homeViewModel!.section(at: .resumable)
        let media = homeViewModel!.showcases[HomeTableViewDataSource.State(rawValue: state.rawValue)!]
        let rotated = false
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = rotated
        coordinator.coordinate(to: .detail)
    }
    
    func setDarkBottomGradient() {
        bottomGradientView.addGradientLayer(colors: [.clear, .black.withAlphaComponent(0.66)],
                                            locations: [0.0, 0.66])
    }
    
    private func analyzeColors(for image: UIImage) -> [UIColor] {
        let c1 = image.averageColor!
        let c2 = image.areaAverage().darkerColor(for: c1)
        let c3 = c2.darkerColor(for: c2)
        let c4 = UIColor.black
        return [c1, c2, c3, c4]
    }
    
    private func setGradient(for image: UIImage) {
        guard let controller = viewModel.coordinator?.viewController else { return }
        
        let colors = analyzeColors(for: image)
        
        gradient = GradientView(on: contentView).applyGradient(with: colors)
        
        controller.dataSource?.style.update(colors: colors)
        
        setPosterShadow(for: colors[2])
    }
    
    private func setPosterShadow(for color: UIColor) {
        contentView.layer.shadow(color, radius: 24.0, opacity: 1.0)
    }
    
    private func setBackgroundColor() {
        backgroundColor = .clear
    }
    
    private func setPosterStroke() {
        let gradient = UIImage.fillGradientStroke(bounds: posterImageView.bounds,
                                                  colors: [.white.withAlphaComponent(0.5), .clear])
        let color = UIColor(patternImage: gradient).cgColor
        posterImageView.layer.borderColor = color
        posterImageView.layer.borderWidth = 1.5
        posterImageView?.layer.cornerRadius = 12.0
    }
    
    private func loadResources() {
        prepareForReuse()
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setPoster(image: image)
                    
                    self.setGradient(for: image)
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setLogo(image: image)
                }
            }
    }
    
    private func setPoster(image: UIImage) {
        posterImageView.image = image
    }
    
    private func setLogo(image: UIImage) {
        logoImageView.image = image
    }
    
    private func setGenres(attributed string: NSMutableAttributedString) {
        genresLabel.attributedText = string
    }
    
    private func setGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    private func setMediaType() {
        guard let typeImagePath = viewModel.typeImagePath, typeImagePath.isNotEmpty else { return }
        typeImageView.image = UIImage(named: typeImagePath)
    }
}

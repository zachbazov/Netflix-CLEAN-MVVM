//
//  ShowcaseView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func didTap()
    
    func setColors(_ colors: [Color])
    func setDarkBottomGradient()
    func setPosterStroke()
    func setGenres(attributed string: NSMutableAttributedString)
    func setMediaType()
    func setGestures()
    func setGradient(for image: UIImage)
    func setLogo(image: UIImage)
    func setPoster(image: UIImage)
    
    func removeNavigationGradientFromSuperview()
    func drawNavigationGradientIfNeeded(_ condition: Bool)
    func drawNavigationBlurIfNeeded(_ condition: Bool)
    func shouldDrawGradientOrBlurIfNeeded()
}

// MARK: - ShowcaseView Type

final class ShowcaseView: UIView, View {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    fileprivate let cellViewModel: ShowcaseTableViewCellViewModel
    
    var viewModel: ShowcaseViewViewModel!
    
    private(set) var panelView: PanelView?
    private(set) var gradient: GradientView?
    
    init(with viewModel: ShowcaseTableViewCellViewModel?) {
        guard let viewModel = viewModel else {
            fatalError("Unexpected \(ShowcaseTableViewCellViewModel.self) value.")
        }
        self.cellViewModel = viewModel
        
        super.init(frame: .zero)
        
        self.nibDidLoad()
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
        
        fetchImages()
    }
    
    func viewWillDeploySubviews() {
        createViewModel()
        createPanelView()
    }
    
    func viewHierarchyWillConfigure() {
        contentView.constraintToSuperview(self)
    }
    
    func viewWillConfigure() {
        guard let viewModel = viewModel else { return }
        
        setDarkBottomGradient()
        setBackgroundColor(.clear)
        setPosterStroke()
        setGenres(attributed: viewModel.attributedGenres)
        setMediaType()
        setGestures()
    }
    
    func prepareForReuse() {
        posterImageView.image = nil
        logoImageView.image = nil
        genresLabel.attributedText = nil
    }
    
    func viewWillDeallocate() {
        panelView?.viewWillDeallocate()
        panelView = nil
        
        gradient?.remove()
        gradient = nil
        
        viewModel = nil
        
        removeNavigationGradientFromSuperview()
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension ShowcaseView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension ShowcaseView: ViewProtocol {
    @objc
    func didTap() {
        guard let controller = viewModel?.coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let coordinator = homeViewModel.coordinator
        else { return }
        
        let state = homeViewModel.dataSourceState.value
        let section = controller.navigationOverlay?.viewModel?.category.toSection()
        let index = MediaTableViewDataSource.State(rawValue: state.rawValue)!
        let media = homeViewModel.showcases[index]
        
        coordinator.coordinate(to: .detail)
        
        guard let detailController = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        detailController.viewModel.media = media
        detailController.viewModel.section = section
        detailController.viewModel.isRotated = false
    }
    
    fileprivate func removeNavigationGradientFromSuperview() {
        guard let controller = viewModel?.coordinator.viewController else { return }
        
        controller.navigationView?.removeGradient()
    }
    
    fileprivate func drawNavigationGradientIfNeeded(_ condition: Bool) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        guard condition else { return }
        
        navigation.apply(.gradient)
    }
    
    fileprivate func drawNavigationBlurIfNeeded(_ condition: Bool) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        guard condition else {
            navigation.apply(.blur)
            
            return
        }
        
        navigation.removeBlur()
    }
    
    fileprivate func shouldDrawGradientOrBlurIfNeeded() {
        guard let controller = viewModel?.coordinator.viewController,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        let condition = browseOverlay.viewModel.isPresented.value
        let isOffsetEqualsZero = controller.dataSource?.primaryOffsetY == .zero
        
        if isOffsetEqualsZero {
            drawNavigationGradientIfNeeded(!condition)
        } else {
            drawNavigationBlurIfNeeded(condition)
        }
    }
    
    fileprivate func setColors(_ colors: [Color]) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        navigation.viewModel?.setColors(colors)
    }
    
    func setDarkBottomGradient() {
        bottomGradientView.addGradientLayer(colors: [.clear, UIColor.black.withAlphaComponent(0.66)],
                                            locations: [0.0, 0.66])
    }
    
    fileprivate func setPosterStroke() {
        let gradient = UIImage.fillGradientStroke(bounds: posterImageView.bounds,
                                                  colors: [UIColor.white.withAlphaComponent(0.5), .clear])
        let color = UIColor(patternImage: gradient).cgColor
        
        posterImageView?.layer.borderColor = color
        posterImageView?.layer.borderWidth = 1.5
        posterImageView?.layer.cornerRadius = 12.0
    }
    
    fileprivate func setGradient(for image: UIImage) {
        guard gradient == nil else { return }
        
        let colors = image.averageColorPalette()
        setColors(colors.toColorArray())
        
        shouldDrawGradientOrBlurIfNeeded()
        
        gradient = GradientView(on: contentView)
            .draw(with: colors)
    }
    
    fileprivate func setPoster(image: UIImage) {
        posterImageView.image = image
    }
    
    fileprivate func setLogo(image: UIImage) {
        logoImageView.image = image
    }
    
    fileprivate func setGenres(attributed string: NSMutableAttributedString) {
        genresLabel.attributedText = string
    }
    
    fileprivate func setGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setMediaType() {
        guard let viewModel = viewModel, let typeImagePath = viewModel.typeImagePath else { return }
        
        typeImageView.image = UIImage(named: typeImagePath)
    }
}

// MARK: - Private Implementation

extension ShowcaseView {
    private func createViewModel() {
        guard let controller = cellViewModel.coordinator.viewController,
              let homeViewModel = controller.viewModel
        else { return }
        
        let state = homeViewModel.dataSourceState.value
        let media = homeViewModel.showcases[state]
        
        viewModel = ShowcaseViewViewModel(media: media, with: homeViewModel)
    }
    
    private func createPanelView() {
        panelView = PanelView(on: panelViewContainer, with: cellViewModel)
    }
    
    private func fetchImages() {
        prepareForReuse()
        
        guard let viewModel = viewModel else { return }
        
        let imageService = Application.app.services.image
        
        imageService.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                self.setGradient(for: image)
                self.setPoster(image: image)
            }
        
        imageService.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                self.setLogo(image: image)
            }
    }
}

//
//  DetailInfoView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var ageRestrictionView: AgeRestrictionView! { get }
    var hdView: HDView! { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - DetailInfoView Type

final class DetailInfoView: View<DetailInfoViewViewModel> {
    @IBOutlet private weak var mediaTypeLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var titlelabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var ageRestrictionViewContainer: UIView!
    @IBOutlet private weak var lengthLabel: UILabel!
    @IBOutlet private weak var hdViewContainer: UIView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var downloadButton: UIButton!
    
    fileprivate var ageRestrictionView: AgeRestrictionView!
    fileprivate var hdView: HDView!
    
    /// Create a detail info object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailInfoViewViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.viewModel = viewModel
        self.ageRestrictionView = AgeRestrictionView(on: ageRestrictionViewContainer)
        self.hdView = HDView(on: hdViewContainer)
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        viewDidDeploySubviews()
        viewDidConfigure()
    }
    
    override func viewDidDeploySubviews() {
        setupGradients()
    }
    
    override func viewDidConfigure() {
        backgroundColor = .black
        
        mediaTypeLabel.text = viewModel.mediaType
        titlelabel.text = viewModel.title
        downloadButton.setTitle(viewModel.downloadButtonTitle, for: .normal)
        lengthLabel.text = viewModel.length
        yearLabel.text = viewModel.duration
        hdViewContainer.isHidden(!viewModel.isHD)
    }
}

// MARK: - ViewInstantiable Implementation

extension DetailInfoView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension DetailInfoView: ViewProtocol {}

// MARK: - Private UI Implementation

extension DetailInfoView {
    private func setupGradients() {
        gradientView.addGradientLayer(
            colors: [UIColor(red: 25.0/255,
                             green: 25.0/255,
                             blue: 25.0/255,
                             alpha: 1.0),
                     .clear],
            locations: [0.3, 1.0])
    }
}

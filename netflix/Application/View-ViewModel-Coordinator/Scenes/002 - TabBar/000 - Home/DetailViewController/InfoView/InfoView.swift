//
//  InfoView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var ageRestrictionView: AgeRestrictionView? { get }
    var hdView: HDView? { get }
    
    func createAgeRestriction()
    func createHD()
    
    func setMediaType(_ string: String)
    func setTitle(_ string: String)
    func setLength(_ string: String)
    func setYear(_ string: String)
    func setButtonTitle(_ string: String)
}

// MARK: - InfoView Type

final class InfoView: UIView, View {
    @IBOutlet private weak var mediaTypeLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var titlelabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var ageRestrictionViewContainer: UIView!
    @IBOutlet private weak var lengthLabel: UILabel!
    @IBOutlet private weak var hdViewContainer: UIView!
    @IBOutlet private(set) weak var playButton: PlayButton!
    @IBOutlet private(set) weak var downloadButton: EntitledButton!
    
    fileprivate var ageRestrictionView: AgeRestrictionView?
    fileprivate var hdView: HDView?
    
    var viewModel: InfoViewViewModel!
    
    /// Create a detail info object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: InfoViewViewModel) {
        super.init(frame: parent.bounds)
        
        self.nibDidLoad()
        
        self.viewModel = viewModel
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewWillDeploySubviews()
        viewWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createAgeRestriction()
        createHD()
    }
    
    func viewWillConfigure() {
        configureGradients()
        
        setBackgroundColor(.black)
        setMediaType(viewModel.mediaType)
        setTitle(viewModel.title)
        setLength(viewModel.length)
        setYear(viewModel.duration)
        setButtonTitle(viewModel.title)
        
        hdViewContainer.isHidden(!viewModel.isHD)
    }
    
    func viewWillDeallocate() {
        ageRestrictionView?.removeFromSuperview()
        ageRestrictionView = nil
        
        hdView?.removeFromSuperview()
        hdView = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension InfoView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension InfoView: ViewProtocol {
    fileprivate func createAgeRestriction() {
        ageRestrictionView = AgeRestrictionView(on: ageRestrictionViewContainer)
    }
    
    fileprivate func createHD() {
        hdView = HDView(on: hdViewContainer)
    }
    
    fileprivate func setMediaType(_ string: String) {
        mediaTypeLabel.text = viewModel.mediaType
    }
    
    fileprivate func setTitle(_ string: String) {
        titlelabel.text = viewModel.title
    }
    
    fileprivate func setLength(_ string: String) {
        lengthLabel.text = viewModel.length
    }
    
    fileprivate func setYear(_ string: String) {
        yearLabel.text = viewModel.duration
    }
    
    fileprivate func setButtonTitle(_ string: String) {
        downloadButton.header.text = "D O W N L O A D"
        downloadButton.content.text = viewModel.title
    }
}

// MARK: - Private Presentation Implementation

extension InfoView {
    private func configureGradients() {
        let colors = [UIColor(red: 25.0/255, green: 25.0/255, blue: 25.0/255, alpha: 1.0), .clear]
        gradientView.addGradientLayer(colors: colors, locations: [0.3, 1.0])
    }
}

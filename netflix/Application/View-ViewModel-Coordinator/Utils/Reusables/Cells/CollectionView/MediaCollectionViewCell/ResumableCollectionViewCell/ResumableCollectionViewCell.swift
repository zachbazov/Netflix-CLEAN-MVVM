//
//  ResumableCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - ResumableCollectionViewCell Type

final class ResumableCollectionViewCell: MediaCollectionViewCell {
    @IBOutlet private weak var actionBoxView: UIView!
    @IBOutlet private weak var optionsButton: UIButton!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private(set) weak var lengthLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDidConfigure()
    }
    
    func viewDidConfigure() {
        configurePlayButton()
        configureProgressView()
        configureGradients()
    }
}

// MARK: - Private Implementation

extension ResumableCollectionViewCell {
    private func configurePlayButton() {
        playButton.layer.borderWidth = 2.0
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.cornerRadius = playButton.bounds.size.height / 2
    }
    
    private func configureProgressView() {
        progressView.layer.cornerRadius = 2.0
        progressView.clipsToBounds = true
    }
    
    private func configureGradients() {
        gradientView.addGradientLayer(colors: [.clear, UIColor.black.withAlphaComponent(0.75)],
                                      locations: [0.0, 1.0])
    }
}

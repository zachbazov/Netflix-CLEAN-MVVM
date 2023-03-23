//
//  DetailDescriptionView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailDescriptionView Type

final class DetailDescriptionView: View<DetailDescriptionViewViewModel> {
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var castLabel: UILabel!
    @IBOutlet private weak var writersLabel: UILabel!
    
    /// Create a description view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailDescriptionViewViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.viewModel = viewModel
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidConfigure() {
        backgroundColor = .black
        
        descriptionTextView.text = viewModel.description
        castLabel.text = viewModel.cast
        writersLabel.text = viewModel.writers
    }
}

// MARK: - ViewInstantiable Implementation

extension DetailDescriptionView: ViewInstantiable {}

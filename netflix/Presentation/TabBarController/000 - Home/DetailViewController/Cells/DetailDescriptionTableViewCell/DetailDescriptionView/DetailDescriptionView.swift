//
//  DetailDescriptionView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailDescriptionView Type

final class DetailDescriptionView: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var castLabel: UILabel!
    @IBOutlet private weak var writersLabel: UILabel!
    
    // MARK: Properties
    
    private let viewModel: DetailDescriptionViewViewModel
    
    // MARK: Initializer
    
    /// Create a description view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailDescriptionViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension DetailDescriptionView {
    private func viewDidConfigure() {
        backgroundColor = .black
        
        descriptionTextView.text = viewModel.description
        castLabel.text = viewModel.cast
        writersLabel.text = viewModel.writers
    }
}

//
//  DescriptionView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func setDescription(_ string: String)
    func setCast(_ string: String)
    func setWriters(_ string: String)
}

// MARK: - DescriptionView Type

final class DescriptionView: UIView, View {
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var castLabel: UILabel!
    @IBOutlet private weak var writersLabel: UILabel!
    
    var viewModel: DescriptionViewViewModel!
    
    /// Create a description view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DescriptionViewViewModel) {
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
        viewWillConfigure()
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.black)
        setDescription(viewModel.description)
        setCast(viewModel.cast)
        setWriters(viewModel.writers)
    }
    
    func viewWillDeallocate() {
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension DescriptionView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension DescriptionView: ViewProtocol {
    fileprivate func setDescription(_ string: String) {
        descriptionTextView.text = string
    }
    
    fileprivate func setCast(_ string: String) {
        castLabel.text = string
    }
    
    fileprivate func setWriters(_ string: String) {
        writersLabel.text = string
    }
}

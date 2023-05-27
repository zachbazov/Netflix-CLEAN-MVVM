//
//  NavigationOverlayFooterView.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var button: UIButton { get }
    
    func createButton() -> UIButton
    func viewDidTap()
}

// MARK: - NavigationOverlayFooterView Type

final class NavigationOverlayFooterView: UIView, View {
    fileprivate lazy var button = createButton()
    
    var viewModel: NavigationOverlayViewModel!
    
    /// Create a navigation overlay footer view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(parent: UIView, viewModel: NavigationOverlayViewModel) {
        super.init(frame: .zero)
        
        self.addSubview(button)
        parent.addSubview(self)
        
        self.constraintToCenter(button)
        self.constraintBottomToSafeArea(toParent: parent, withHeightAnchor: 60.0)
        
        self.viewModel = viewModel
        
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func viewDidConfigure() {
        backgroundColor = .clear
        alpha = .zero
    }
}

// MARK: - ViewProtocol Implementation

extension NavigationOverlayFooterView: ViewProtocol {
    fileprivate func createButton() -> UIButton {
        let button = UIButton(type: .system)
        let systemName = "xmark.circle.fill"
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: systemName)?.whiteRendering(with: symbolConfiguration)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
        return button
    }
    
    @objc
    fileprivate func viewDidTap() {
        viewModel.isPresented.value = false
    }
}

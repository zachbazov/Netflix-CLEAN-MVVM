//
//  NavigationOverlayFooterView.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - NavigationOverlayFooterView Type

final class NavigationOverlayFooterView: UIView {
    private let viewModel: NavigationOverlayViewModel
    private lazy var button = createButton()
    /// Create a navigation overlay footer view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(parent: UIView, viewModel: NavigationOverlayViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.addSubview(button)
        self.constraintToCenter(button)
        parent.addSubview(self)
        self.constraintBottom(toParent: parent, withHeightAnchor: 60.0)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension NavigationOverlayFooterView {
    private func createButton() -> UIButton {
        let button = UIButton(type: .system)
        let systemName = "xmark.circle.fill"
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: systemName)?.whiteRendering(with: symbolConfiguration)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
        return button
    }
    
    private func viewDidConfigure() {
        backgroundColor = .clear
        alpha = .zero
    }
    
    @objc
    private func viewDidTap() {
        viewModel.isPresented.value = false
    }
}

//
//  DetailNavigationViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - DetailNavigationViewItemConfiguration Type

final class DetailNavigationViewItemConfiguration {
    
    // MARK: Properties
    
    private weak var view: DetailNavigationViewItem!
    private weak var navigationView: DetailNavigationView!
    
    // MARK: Initializer
    
    /// Create a navigation view item configuration object.
    /// - Parameters:
    ///   - view: Corresponding view.
    ///   - navigationView: Root navigation view object.
    init(on view: DetailNavigationViewItem, with navigationView: DetailNavigationView) {
        self.view = view
        self.navigationView = navigationView
        self.viewDidRegisterRecognizers()
    }
    
    // MARK: Deinitializer
    
    deinit {
        view = nil
        navigationView = nil
    }
}

// MARK: - UI Setup

extension DetailNavigationViewItemConfiguration {
    private func viewDidRegisterRecognizers() {
        view.button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
    }
    
    @objc
    func viewDidTap() {
        view.isSelected.toggle()
        
        navigationView.stateDidChange(view: view)
    }
}

// MARK: - DetailNavigationViewItem Type

final class DetailNavigationViewItem: UIView {
    
    // MARK: Properties
    
    private var configuration: DetailNavigationViewItemConfiguration!
    private var viewModel: DetailNavigationViewItemViewModel!
    private lazy var indicatorView = createIndicatorView()
    fileprivate lazy var button = createButton()
    var isSelected = false
    private(set) var widthConstraint: NSLayoutConstraint!
    
    // MARK: Initializer
    
    /// Create a navigation view item object.
    /// - Parameters:
    ///   - navigationView: Root navigation view object.
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(navigationView: DetailNavigationView, on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: parent.bounds)
        self.tag = parent.tag
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.viewModel = DetailNavigationViewItemViewModel(with: self)
        self.configuration = DetailNavigationViewItemConfiguration(on: self, with: navigationView)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Deinitializer
    
    deinit {
        widthConstraint = nil
        configuration = nil
        viewModel = nil
    }
}

// MARK: - UI Setup

extension DetailNavigationViewItem {
    private func createIndicatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemRed
        addSubview(view)
        return view
    }
    
    private func createButton() -> UIButton {
        let view = UIButton(type: .system)
        view.setTitle(viewModel.title, for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        addSubview(view)
        return view
    }
    
    private func viewDidConfigure() {
        widthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: bounds.width)
        chainConstraintToSuperview(linking: indicatorView, to: button, withWidthAnchor: widthConstraint)
    }
}

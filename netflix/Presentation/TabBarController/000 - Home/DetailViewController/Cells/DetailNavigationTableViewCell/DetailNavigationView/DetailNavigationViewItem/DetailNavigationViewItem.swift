//
//  DetailNavigationViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

final class DetailNavigationViewItemConfiguration {
    private weak var view: DetailNavigationViewItem!
    private weak var navigationView: DetailNavigationView!
    /// Create a navigation view item configuration object.
    /// - Parameters:
    ///   - view: Corresponding view.
    ///   - navigationView: Root navigation view object.
    init(on view: DetailNavigationViewItem, with navigationView: DetailNavigationView) {
        self.view = view
        self.navigationView = navigationView
        self.viewDidRegisterRecognizers()
        self.viewDidConfigure()
    }
    
    deinit {
        view = nil
        navigationView = nil
    }
}

extension DetailNavigationViewItemConfiguration {
    private func viewDidRegisterRecognizers() {
        view.button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
    }
    
    private func viewDidConfigure() {
        if navigationView.viewModel.media.type == .series {
            navigationView.viewModel.navigationViewState.value = .episodes
            navigationView.leadingViewContainer.isHidden(false)
            navigationView.centerViewContainer.isHidden(true)
        } else {
            navigationView.viewModel.navigationViewState.value = .trailers
            navigationView.leadingViewContainer.isHidden(true)
            navigationView.centerViewContainer.isHidden(false)
        }
    }
    
    @objc
    func viewDidTap() {
        view.isSelected.toggle()
        
        navigationView.stateDidChange(view: view)
    }
}

final class DetailNavigationViewItem: UIView {
    private var configuration: DetailNavigationViewItemConfiguration!
    private var viewModel: DetailNavigationViewItemViewModel!
    private lazy var indicatorView = createIndicatorView()
    fileprivate lazy var button = createButton()
    var isSelected = false
    private(set) var widthConstraint: NSLayoutConstraint!
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
    
    deinit {
        widthConstraint = nil
        configuration = nil
        viewModel = nil
    }
    
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
}

extension DetailNavigationViewItem {
    private func viewDidConfigure() {
        widthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: bounds.width)
        chainConstraintToSuperview(linking: indicatorView, to: button, withWidthAnchor: widthConstraint)
    }
}

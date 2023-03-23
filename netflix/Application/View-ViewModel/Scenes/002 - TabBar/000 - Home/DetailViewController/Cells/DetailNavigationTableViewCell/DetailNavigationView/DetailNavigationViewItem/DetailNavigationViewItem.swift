//
//  DetailNavigationViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - ConfigurationProtocol Type

private protocol ConfigurationProtocol {
    var view: DetailNavigationViewItem! { get }
    var navigationView: DetailNavigationView! { get }
    
    func viewDidRegisterRecognizers()
    func viewDidTap()
}

// MARK: - DetailNavigationViewItemConfiguration Type

final class DetailNavigationViewItemConfiguration {
    fileprivate weak var view: DetailNavigationViewItem!
    fileprivate weak var navigationView: DetailNavigationView!
    
    /// Create a navigation view item configuration object.
    /// - Parameters:
    ///   - view: Corresponding view.
    ///   - navigationView: Root navigation view object.
    init(on view: DetailNavigationViewItem, with navigationView: DetailNavigationView) {
        self.view = view
        self.navigationView = navigationView
        self.viewDidRegisterRecognizers()
    }
    
    deinit {
        view = nil
        navigationView = nil
    }
}

// MARK: - ConfigurationProtocol Implementation

extension DetailNavigationViewItemConfiguration: ConfigurationProtocol {
    fileprivate func viewDidRegisterRecognizers() {
        view.button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
    }
    
    @objc
    func viewDidTap() {
        view.isSelected.toggle()
        
        navigationView.stateDidChange(view: view)
    }
}

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var configuration: DetailNavigationViewItemConfiguration! { get }
    var indicatorView: UIView { get }
    var button: UIButton { get }
    var isSelected: Bool { get }
    var widthConstraint: NSLayoutConstraint! { get }
    
    func createIndicatorView() -> UIView
    func createButton() -> UIButton
}

// MARK: - DetailNavigationViewItem Type

final class DetailNavigationViewItem: View<DetailNavigationViewItemViewModel> {
    fileprivate var configuration: DetailNavigationViewItemConfiguration!
    fileprivate lazy var indicatorView: UIView = createIndicatorView()
    fileprivate lazy var button = createButton()
    var isSelected = false
    fileprivate(set) var widthConstraint: NSLayoutConstraint!
    
    /// Create a navigation view item object.
    /// - Parameters:
    ///   - navigationView: Root navigation view object.
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(navigationView: DetailNavigationView,
         on parent: UIView,
         with viewModel: DetailViewModel) {
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
    
    override func viewDidConfigure() {
        widthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: bounds.width)
        chainConstraintToSuperview(linking: indicatorView, to: button, withWidthAnchor: widthConstraint)
    }
}

// MARK: - ViewProtocol Implementation

extension DetailNavigationViewItem: ViewProtocol {
    fileprivate func createIndicatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemRed
        addSubview(view)
        return view
    }
    
    fileprivate func createButton() -> UIButton {
        let view = UIButton(type: .system)
        view.setTitle(viewModel.title, for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        addSubview(view)
        return view
    }
}

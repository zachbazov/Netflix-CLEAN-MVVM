//
//  DetailNavigationViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var indicatorView: UIView { get }
    var button: UIButton { get }
    
    var navigationView: DetailNavigationView? { get }
    
    var widthConstraint: NSLayoutConstraint? { get }
    
    func createIndicatorView() -> UIView
    func createButton() -> UIButton
    
    func viewDidTap()
}

// MARK: - DetailNavigationViewItem Type

final class DetailNavigationViewItem: View<DetailNavigationViewItemViewModel> {
    fileprivate lazy var indicatorView: UIView = createIndicatorView()
    fileprivate lazy var button = createButton()
    
    weak var navigationView: DetailNavigationView?
    
    fileprivate(set) var widthConstraint: NSLayoutConstraint?
    
    /// Create a navigation view item object.
    /// - Parameters:
    ///   - navigationView: Root navigation view object.
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView,
         with viewModel: DetailViewModel) {
        super.init(frame: parent.bounds)
        
        self.tag = parent.tag
        
        self.viewModel = DetailNavigationViewItemViewModel(with: self)
        
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
        viewWillTargetSubviews()
    }
    
    override func viewWillConfigure() {
        configureConstraint()
    }
    
    override func viewWillTargetSubviews() {
        button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
    }
    
    override func viewWillDeallocate() {
        widthConstraint = nil
        navigationView = nil
        viewModel = nil
        
        removeFromSuperview()
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
    
    @objc
    func viewDidTap() {
        viewModel?.isSelected.toggle()
        
        navigationView?.didSelect(self)
    }
}

// MARK: - Private Presentation Implementation

extension DetailNavigationViewItem {
    private func configureConstraint() {
        widthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: bounds.width)
        
        guard let constraint = widthConstraint else { return }
        self.chainConstraintToSuperview(linking: indicatorView, to: button, withWidthAnchor: constraint)
    }
}

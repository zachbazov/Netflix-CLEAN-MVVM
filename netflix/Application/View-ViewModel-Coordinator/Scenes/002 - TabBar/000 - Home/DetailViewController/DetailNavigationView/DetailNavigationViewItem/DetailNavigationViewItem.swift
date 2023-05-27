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
    var indicatorWidth: NSLayoutConstraint { get }
    var button: UIButton { get }
    
    func createIndicatorView() -> UIView
    func createIndicatorConstraint() -> NSLayoutConstraint
    func createButton() -> UIButton
    
    func willSelect()
}

// MARK: - DetailNavigationViewItem Type

final class DetailNavigationViewItem: UIView, View {
    fileprivate lazy var indicatorView: UIView = createIndicatorView()
    fileprivate(set) lazy var indicatorWidth: NSLayoutConstraint = createIndicatorConstraint()
    fileprivate lazy var button = createButton()
    
    var viewModel: DetailNavigationViewItemViewModel!
    
    /// Create a navigation view item object.
    /// - Parameters:
    ///   - navigationView: Root navigation view object.
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        
        self.tag = parent.tag
        
        self.viewModel = DetailNavigationViewItemViewModel(item: self, with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillTargetSubviews()
    }
    
    func viewHierarchyWillConfigure() {
        indicatorView.addToHierarchy(on: self)
        button.addToHierarchy(on: self)
        
        self.chainConstraintToSuperview(linking: indicatorView,
                                        to: button,
                                        withWidthAnchor: indicatorWidth)
    }
    
    func viewWillTargetSubviews() {
        button.addTarget(self, action: #selector(willSelect), for: .touchUpInside)
    }
    
    func viewWillDeallocate() {
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension DetailNavigationViewItem: ViewProtocol {
    fileprivate func createIndicatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }
    
    fileprivate func createButton() -> UIButton {
        let view = UIButton(type: .system)
        view.setTitle(viewModel.title, for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        return view
    }
    
    fileprivate func createIndicatorConstraint() -> NSLayoutConstraint {
        return indicatorView.widthAnchor.constraint(equalToConstant: bounds.width)
    }
    
    @objc
    func willSelect() {
        guard let controller = viewModel?.coordinator.viewController,
              let dataSource = controller.dataSource,
              let navigation = dataSource.navigationCell?.navigationView,
              let state = DetailNavigationView.State(rawValue: tag)
        else { return }
        
        viewModel?.isSelected.toggle()
        
        navigation.viewModel?.stateWillChange(state)
    }
}

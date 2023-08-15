//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 06/05/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func createNavigationBar()
    func createSegmentControl()
    
    func addGradient(with colors: [UIColor])
    func removeGradient()
    func addBlur()
    func removeBlur()
    func apply(_ style: NavigationView.Style)
}

// MARK: - NavigationView Type

final class NavigationView: UIView, View {
    @IBOutlet private weak var navigationContainer: UIView!
    @IBOutlet private weak var segmentContainer: UIView!
    @IBOutlet weak var navigationHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    
    private(set) var navigationBar: NavigationBarView?
    private(set) var segmentControl: SegmentControlView?
    
    private(set) var blur: BlurView?
    private(set) var gradient: GradientView?
    
    var viewModel: NavigationViewModel!
    
    init(with viewModel: HomeViewModel) {
        super.init(frame: .zero)
        
        self.nibDidLoad()
        
        self.viewModel = NavigationViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    deinit {
        viewWillDeallocate()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func viewDidLoad() {
        viewWillDeploySubviews()
    }
    
    func viewWillDeploySubviews() {
        createNavigationBar()
        createSegmentControl()
    }
    
    func viewWillDeallocate() {
        navigationBar?.viewWillDeallocate()
        segmentControl?.viewWillDeallocate()
        
        blur?.remove()
        gradient?.remove()
        
        blur = nil
        gradient = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension NavigationView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension NavigationView: ViewProtocol {
    fileprivate func createNavigationBar() {
        guard let homeViewModel = viewModel?.coordinator.viewController?.viewModel else { return }
        
        navigationBar = NavigationBarView(with: homeViewModel)
        navigationBar?
            .addToHierarchy(on: navigationContainer)
            .constraintToSuperview(navigationContainer)
    }
    
    fileprivate func createSegmentControl() {
        guard let homeViewModel = viewModel?.coordinator.viewController?.viewModel else { return }
        
        segmentControl = SegmentControlView(on: segmentContainer, with: homeViewModel)
    }
    
    fileprivate func addGradient(with colors: [UIColor]) {
        guard gradient == nil else { return }
        
        gradient = GradientView(on: self)
            .draw(with: colors.reversed())
    }
    
    func removeGradient() {
        guard let gradient = gradient else { return }
        
        gradient.remove()
        
        self.gradient = nil
    }
    
    fileprivate func addBlur() {
        guard blur == nil else { return }
        
        let effect = UIBlurEffect(style: .dark)
        
        blur = BlurView(on: self, effect: effect)
            .draw()
    }
    
    func removeBlur() {
        guard let blur = blur else { return }
        
        blur.remove()
        
        self.blur = nil
    }
    
    func apply(_ style: NavigationView.Style) {
        guard let colors = viewModel?.colors, !colors.isEmpty else { return }
        
        switch style {
        case .blur:
//            removeBlur()
            removeGradient()
            addBlur()
        case .gradient:
//            removeGradient()
            removeBlur()
            addGradient(with: colors.toUIColorArray())
        }
    }
}

// MARK: - Style Type

extension NavigationView {
    /// Style representation type.
    enum Style {
        case blur
        case gradient
    }
}

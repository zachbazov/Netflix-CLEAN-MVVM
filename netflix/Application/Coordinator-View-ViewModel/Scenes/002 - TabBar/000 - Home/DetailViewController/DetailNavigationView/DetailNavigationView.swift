//
//  DetailNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var leadingItem: DetailNavigationViewItem? { get }
    var centerItem: DetailNavigationViewItem? { get }
    var trailingItem: DetailNavigationViewItem? { get }
    
    func didSelect(_ view: DetailNavigationViewItem)
    func stateDidChange(_ state: DetailNavigationView.State)
    func indicatorValueWillChange(for state: DetailNavigationView.State)
    func buttonAppearanceWillChange(for state: DetailNavigationView.State)
    func collectionStateWillChange(for state: DetailNavigationView.State)
}

// MARK: - DetailNavigationView Type

final class DetailNavigationView: UIView, View {
    @IBOutlet private(set) weak var leadingViewContainer: UIView!
    @IBOutlet private(set) weak var centerViewContainer: UIView!
    @IBOutlet private(set) weak var trailingViewContrainer: UIView!
    
    fileprivate(set) var leadingItem: DetailNavigationViewItem?
    fileprivate(set) var centerItem: DetailNavigationViewItem?
    fileprivate(set) var trailingItem: DetailNavigationViewItem?
    
    var viewModel: DetailNavigationViewModel!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        
        self.nibDidLoad()
        
        self.viewModel = DetailNavigationViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillBindObservers()
    }
    
    func viewWillDeploySubviews() {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel else { return }
        
        leadingItem = DetailNavigationViewItem(on: leadingViewContainer, with: viewModel)
        centerItem = DetailNavigationViewItem(on: centerViewContainer, with: viewModel)
        trailingItem = DetailNavigationViewItem(on: trailingViewContrainer, with: viewModel)
    }
    
    func viewHierarchyWillConfigure() {
        leadingItem?
            .addToHierarchy(on: leadingViewContainer)
            .constraintToSuperview(leadingViewContainer)
        
        centerItem?
            .addToHierarchy(on: centerViewContainer)
            .constraintToSuperview(centerViewContainer)
        
        trailingItem?
            .addToHierarchy(on: trailingViewContrainer)
            .constraintToSuperview(trailingViewContrainer)
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.black)
    }
    
    func viewWillBindObservers() {
        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .episodes:
                self.didSelect(self.leadingItem!)
            case .trailers:
                self.didSelect(self.centerItem!)
            case .similarContent:
                self.didSelect(self.trailingItem!)
            }
        }
    }
    
    func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        leadingItem?.removeFromSuperview()
        centerItem?.removeFromSuperview()
        trailingItem?.removeFromSuperview()
        
        leadingItem = nil
        centerItem = nil
        trailingItem = nil
        
        viewModel = nil
    }
}

// MARK: - ViewInstantiable Implementation

extension DetailNavigationView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension DetailNavigationView: ViewProtocol {
    func didSelect(_ view: DetailNavigationViewItem) {
        guard let state = State(rawValue: view.tag) else { return }
        
        stateDidChange(state)
        
        collectionStateWillChange(for: state)
    }
    
    fileprivate func stateDidChange(_ state: DetailNavigationView.State) {
        buttonAppearanceWillChange(for: state)
        indicatorValueWillChange(for: state)
        
        animateUsingSpring(withDuration: 0.5, withDamping: 1.0, initialSpringVelocity: 1.0)
    }
    
    fileprivate func indicatorValueWillChange(for state: DetailNavigationView.State) {
        switch state {
        case .episodes:
            leadingItem?.indicatorWidth.constant = leadingViewContainer.bounds.width
            centerItem?.indicatorWidth.constant = .zero
            trailingItem?.indicatorWidth.constant = .zero
        case .trailers:
            leadingItem?.indicatorWidth.constant = .zero
            centerItem?.indicatorWidth.constant = centerViewContainer.bounds.width
            trailingItem?.indicatorWidth.constant = .zero
        case .similarContent:
            leadingItem?.indicatorWidth.constant = .zero
            centerItem?.indicatorWidth.constant = .zero
            trailingItem?.indicatorWidth.constant = trailingViewContrainer.bounds.width
        }
    }
    
    fileprivate func buttonAppearanceWillChange(for state: DetailNavigationView.State) {
        switch state {
        case .episodes:
            leadingViewContainer.isHidden(false)
            centerViewContainer.isHidden(true)
        case .trailers:
            leadingViewContainer.isHidden(true)
            centerViewContainer.isHidden(false)
        default: break
        }
    }
    
    fileprivate func collectionStateWillChange(for state: DetailNavigationView.State) {
        guard let controller = viewModel?.coordinator.viewController,
              let collectionCell = controller.dataSource?.collectionCell
        else { return }
        
        switch state {
        case .episodes:
            collectionCell.viewModel?.stateWillChange(.series)
        case .trailers:
            collectionCell.viewModel?.stateWillChange(.film)
        case .similarContent:
            collectionCell.viewModel?.stateWillChange(.similarContent)
        }
    }
}

// MARK: - State Type

extension DetailNavigationView {
    /// Item representation type.
    enum State: Int {
        case episodes
        case trailers
        case similarContent
    }
}

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
    func setIndicator(for state: DetailNavigationView.State)
}

// MARK: - DetailNavigationView Type

final class DetailNavigationView: View<DetailNavigationViewModel> {
    @IBOutlet private(set) weak var leadingViewContainer: UIView!
    @IBOutlet private(set) weak var centerViewContainer: UIView!
    @IBOutlet private(set) weak var trailingViewContrainer: UIView!
    
    fileprivate(set) var leadingItem: DetailNavigationViewItem?
    fileprivate(set) var centerItem: DetailNavigationViewItem?
    fileprivate(set) var trailingItem: DetailNavigationViewItem?
    
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
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillBindObservers()
    }
    
    override func viewWillDeploySubviews() {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel else { return }
        
        leadingItem = DetailNavigationViewItem(on: leadingViewContainer, with: viewModel)
        centerItem = DetailNavigationViewItem(on: centerViewContainer, with: viewModel)
        trailingItem = DetailNavigationViewItem(on: trailingViewContrainer, with: viewModel)
    }
    
    override func viewHierarchyWillConfigure() {
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
    
    override func viewWillConfigure() {
        setBackgroundColor(.black)
        
        configureStateForMediaType()
        configureInitialState()
    }
    
    override func viewWillBindObservers() {
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
            
            guard let ds = self.viewModel.coordinator.viewController?.dataSource else { return }
            mainQueueDispatch {
                ds.collectionCell?.detailCollectionView?.dataSourceDidChange()
                ds.reloadData(at: .collection)
            }
        }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDeallocate() {
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
        
//        configureStateForMediaType()
        
        setIndicator(for: state)
        
        animateUsingSpring(withDuration: 0.5, withDamping: 1.0, initialSpringVelocity: 1.0)
    }
    
    fileprivate func setIndicator(for state: DetailNavigationView.State) {
        switch state {
        case .episodes:
            leadingItem?.indicatorWidth.constant = leadingItem?.bounds.width ?? .zero
            centerItem?.indicatorWidth.constant = .zero
            trailingItem?.indicatorWidth.constant = .zero
        case .trailers:
            leadingItem?.indicatorWidth.constant = .zero
            centerItem?.indicatorWidth.constant = centerItem?.bounds.width ?? .zero
            trailingItem?.indicatorWidth.constant = .zero
        case .similarContent:
            leadingItem?.indicatorWidth.constant = .zero
            centerItem?.indicatorWidth.constant = .zero
            trailingItem?.indicatorWidth.constant = trailingItem?.bounds.width ?? .zero
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

// MARK: - Private Presentation Implementation

extension DetailNavigationView {
    private func configureStateForMediaType() {
        guard let type = Media.MediaType(rawValue: viewModel.media.type) else { return }
        
        switch type {
        case .series:
            viewModel.state.value = .episodes
            
            leadingViewContainer.isHidden(false)
            centerViewContainer.isHidden(true)
        case .film:
            viewModel.state.value = .trailers
            
            leadingViewContainer.isHidden(true)
            centerViewContainer.isHidden(false)
        default: return
        }
    }
    
    private func configureInitialState() {
        guard let view = viewModel.state.value == .episodes ? leadingItem : centerItem else { return }
        
        didSelect(view)
    }
}

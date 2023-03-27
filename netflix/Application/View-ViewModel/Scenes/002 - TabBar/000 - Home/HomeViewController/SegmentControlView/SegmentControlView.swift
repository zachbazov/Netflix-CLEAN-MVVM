//
//  SegmentControlView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var tvShowsItemView: NavigationViewItem! { get }
    var moviesItemView: NavigationViewItem! { get }
    var categoriesItemView: NavigationViewItem! { get }
}

// MARK: - NavigationView Type

final class SegmentControlView: View<SegmentControlViewViewModel> {
    @IBOutlet private(set) weak var bottomContainer: UIView!
    @IBOutlet private(set) weak var tvShowsItemViewContainer: UIView!
    @IBOutlet private(set) weak var moviesItemViewContainer: UIView!
    @IBOutlet private(set) weak var categoriesItemViewContainer: UIView!
    @IBOutlet private(set) weak var itemsCenterXConstraint: NSLayoutConstraint!
    
    fileprivate(set) var tvShowsItemView: NavigationViewItem!
    fileprivate(set) var moviesItemView: NavigationViewItem!
    fileprivate(set) var categoriesItemView: NavigationViewItem!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.tvShowsItemView = NavigationViewItem(on: self.tvShowsItemViewContainer, with: viewModel)
        self.moviesItemView = NavigationViewItem(on: self.moviesItemViewContainer, with: viewModel)
        self.categoriesItemView = NavigationViewItem(on: self.categoriesItemViewContainer, with: viewModel)
        let items: [NavigationViewItem] = [self.tvShowsItemView, self.moviesItemView, self.categoriesItemView]
        self.viewModel = SegmentControlViewViewModel(items: items, with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewDidBindObservers()
    }
    
    override func viewDidBindObservers() {
        viewModel.state.observe(on: self) { [weak self] state in
            self?.viewModel.stateDidChange(state)
            
            let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as? HomeViewController
            homeViewController?.navigationOverlayView?.viewModel.navigationViewStateDidChange(state)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        viewModel.state.remove(observer: self)
        printIfDebug(.success, "Removed `NavigationView` observers.")
    }
}

// MARK: - ViewInstantiable Implementation

extension SegmentControlView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension SegmentControlView: ViewProtocol {}

//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var navigationOverlayView: NavigationOverlayView! { get }
    var homeItemView: NavigationViewItem! { get }
    var airPlayItemView: NavigationViewItem! { get }
    var accountItemView: NavigationViewItem! { get }
    var tvShowsItemView: NavigationViewItem! { get }
    var moviesItemView: NavigationViewItem! { get }
    var categoriesItemView: NavigationViewItem! { get }
}

// MARK: - NavigationView Type

final class NavigationView: View<NavigationViewViewModel> {
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var homeItemViewContainer: UIView!
    @IBOutlet private weak var airPlayItemViewContainer: UIView!
    @IBOutlet private weak var searchItemViewContainer: UIView!
    @IBOutlet private weak var accountItemViewContainer: UIView!
    @IBOutlet private(set) weak var tvShowsItemViewContainer: UIView!
    @IBOutlet private(set) weak var moviesItemViewContainer: UIView!
    @IBOutlet private(set) weak var categoriesItemViewContainer: UIView!
    @IBOutlet private(set) weak var itemsCenterXConstraint: NSLayoutConstraint!
    
    var navigationOverlayView: NavigationOverlayView!
    
    fileprivate(set) var homeItemView: NavigationViewItem!
    fileprivate var airPlayItemView: NavigationViewItem!
    fileprivate var searchItemView: NavigationViewItem!
    fileprivate var accountItemView: NavigationViewItem!
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
        
        self.homeItemView = NavigationViewItem(on: self.homeItemViewContainer, with: viewModel)
        self.airPlayItemView = NavigationViewItem(on: self.airPlayItemViewContainer, with: viewModel)
        self.searchItemView = NavigationViewItem(on: self.searchItemViewContainer, with: viewModel)
        self.accountItemView = NavigationViewItem(on: self.accountItemViewContainer, with: viewModel)
        self.tvShowsItemView = NavigationViewItem(on: self.tvShowsItemViewContainer, with: viewModel)
        self.moviesItemView = NavigationViewItem(on: self.moviesItemViewContainer, with: viewModel)
        self.categoriesItemView = NavigationViewItem(on: self.categoriesItemViewContainer, with: viewModel)
        let items: [NavigationViewItem] = [self.homeItemView, self.airPlayItemView,
                                           self.accountItemView, self.tvShowsItemView,
                                           self.moviesItemView, self.categoriesItemView,
                                           self.searchItemView]
        self.viewModel = NavigationViewViewModel(items: items, with: viewModel)
        // Updates root coordinator's `navigationView` property.
        viewModel.coordinator?.viewController?.navigationView = self
        
        self.navigationOverlayView = NavigationOverlayView(with: viewModel)
        
        self.viewDidLoad()
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        navigationOverlayView?.removeFromSuperview()
        navigationOverlayView = nil
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewDidDeploySubviews()
        viewDidBindObservers()
        
//        self.layer.shadow(.black, radius: 16.0, opacity: 1.0)
    }
    
    override func viewDidDeploySubviews() {
        setupGradients()
    }
    
    override func viewDidBindObservers() {
        viewModel.state.observe(on: self) { [weak self] state in
            self?.viewModel.stateDidChange(state)
            self?.navigationOverlayView.viewModel.navigationViewStateDidChange(state)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        viewModel.state.remove(observer: self)
        printIfDebug(.success, "Removed `NavigationView` observers.")
    }
}

// MARK: - ViewInstantiable Implementation

extension NavigationView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension NavigationView: ViewProtocol {}

// MARK: - Private UI Implementation

extension NavigationView {
    private func setupGradients() {
        let rect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: bounds.height)
        gradientView.addGradientLayer(
            colors: [.black.withAlphaComponent(0.9),
                     .black.withAlphaComponent(0.7),
                     .clear],
            locations: [0.0, 0.3, 1.0])
        gradientView.frame = rect
    }
}

// MARK: - State Type

extension NavigationView {
    /// Item representation type.
    enum State: Int, CaseIterable {
        case home
        case airPlay
        case account
        case tvShows
        case movies
        case categories
        case search
    }
}

// MARK: - Valuable Implementation

extension NavigationView.State: Valuable {
    var stringValue: String {
        switch self {
        case .home: return Localization.TabBar.Home.Navigation().home
        case .tvShows: return Localization.TabBar.Home.Navigation().tvShows
        case .movies: return Localization.TabBar.Home.Navigation().movies
        case .categories: return Localization.TabBar.Home.Navigation().categories
        case .airPlay: return Localization.TabBar.Home.Navigation().airPlay
        case .search: return ""
        case .account: return Localization.TabBar.Home.Navigation().account
        }
    }
}

//
//  NavigationViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 17/09/2022.
//

import UIKit

final class NavigationViewItemConfiguration {
    private weak var item: NavigationViewItem!
    /// Create a configuration object for the item.
    /// - Parameter item: Corresponding view.
    init(with item: NavigationViewItem) {
        self.item = item
        self.viewDidLoad()
    }
    
    deinit {
        item?.removeFromSuperview()
        item = nil
    }
}

extension NavigationViewItemConfiguration {
    private func viewDidLoad() {
        viewDidConfigure(item: item)
    }
    
    private func viewDidConfigure(item: NavigationViewItem) {
        self.item = item
        
        guard let state = NavigationView.State(rawValue: item.tag) else { return }
        
        item.addSubview(item.button)
        item.button.frame = item.bounds
        item.button.layer.shadow(.black, radius: 3.0, opacity: 0.4)
        item.button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
        
        let image: UIImage!
        let symbolConfiguration: UIImage.SymbolConfiguration!
        switch state {
        case .home:
            image = UIImage(named: item.viewModel.image)?
                .withRenderingMode(.alwaysOriginal)
            item.button.setImage(image, for: .normal)
        case .airPlay:
            symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16.0)
            image = UIImage(systemName: item.viewModel.image)?
                .whiteRendering(with: symbolConfiguration)
            item.button.setImage(image, for: .normal)
        case .account:
            symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17.0)
            image = UIImage(systemName: item.viewModel.image)?
                .whiteRendering(with: symbolConfiguration)
            item.button.setImage(image, for: .normal)
        default:
            item.button.setTitleColor(.white, for: .normal)
            item.button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
            item.button.setTitle(item.viewModel.title, for: .normal)
        }
    }
    
    @objc
    private func viewDidTap() {
        guard let navigation = item.viewModel.coordinator.viewController?.navigationView,
              let state = NavigationView.State(rawValue: item.tag) else {
            return
        }
        navigation.viewModel.state.value = state
    }
}

final class NavigationViewItem: UIView {
    fileprivate lazy var button = UIButton(type: .system)
    fileprivate var configuration: NavigationViewItemConfiguration!
    var viewModel: NavigationViewItemViewModel!
    /// Create a navigation view item object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        self.tag = parent.tag
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.viewModel = NavigationViewItemViewModel(tag: self.tag, with: viewModel)
        self.configuration = NavigationViewItemConfiguration(with: self)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        configuration = nil
        viewModel = nil
    }
}

extension NavigationViewItem {
    /// Configure an item and change it according to the navigation state.
    /// - Parameter state: Corresponding navigation state.
    func viewDidConfigure(for state: NavigationView.State) {
        guard let tag = NavigationView.State(rawValue: tag) else { return }
        /// Release changes for `categories` item depending the navigation state.
        if case .home = state, case .categories = tag {
            button.setTitle(viewModel.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        } else if case .tvShows = state, case .categories = tag {
            button.setTitle("All \(viewModel.title!)", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        } else if case .movies = state, case .categories = tag {
            button.setTitle("All \(viewModel.title!)", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        }
    }
}

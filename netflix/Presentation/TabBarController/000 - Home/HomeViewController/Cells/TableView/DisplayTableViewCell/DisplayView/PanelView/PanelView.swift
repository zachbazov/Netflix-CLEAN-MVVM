//
//  PanelView.swift
//  netflix
//
//  Created by Zach Bazov on 10/09/2022.
//

import UIKit

// MARK: - PanelView Type

final class PanelView: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private(set) weak var leadingItemViewContainer: UIView!
    @IBOutlet private(set) weak var trailingItemViewContainer: UIView!
    
    // MARK: Type's Properties
    
    var viewModel: DisplayTableViewCellViewModel!
    var leadingItemView: PanelViewItem!
    var trailingItemView: PanelViewItem!
    
    // MARK: Initializer
    
    /// Create a panel view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DisplayTableViewCellViewModel) {
        self.viewModel = viewModel
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.leadingItemView = PanelViewItem(on: self.leadingItemViewContainer, with: viewModel)
        self.trailingItemView = PanelViewItem(on: self.trailingItemViewContainer, with: viewModel)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Deinitializer
    
    deinit {
        removeObservers()
        leadingItemView?.removeFromSuperview()
        trailingItemView?.removeFromSuperview()
        leadingItemView = nil
        trailingItemView = nil
        viewModel = nil
    }
}

// MARK: - UI Setup

extension PanelView {
    private func viewDidConfigure() {
        playButton.layer.cornerRadius = 6.0
        playButton.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
    }
    
    @objc
    private func playDidTap() {
        /// Allocate a new detail controller.
        let coordinator = viewModel.coordinator!
        let section = viewModel.sectionAt(.display)
        let media = viewModel.presentedMedia.value!
        let rotated = true
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = rotated
        coordinator.showScreen(.detail)
    }
}

// MARK: - Observers

extension PanelView {
    func removeObservers() {
        printIfDebug(.success, "Removed `PanelView` observers.")
        leadingItemView?.viewModel?.removeObservers()
        trailingItemView?.viewModel.removeObservers()
    }
}

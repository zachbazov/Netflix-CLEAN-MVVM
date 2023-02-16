//
//  PanelView.swift
//  netflix
//
//  Created by Zach Bazov on 10/09/2022.
//

import UIKit

// MARK: - PanelViewObserving Type

private protocol PanelViewObserving {
    
}

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure()
    func playDidTap()
}

private protocol ViewOutput {
    var leadingItem: PanelViewItem! { get }
    var trailingItem: PanelViewItem! { get }
}

private typealias ViewProtocol = ViewInput

// MARK: - PanelView Type

final class PanelView: UIView, ViewInstantiable {
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private(set) weak var leadingItemContainer: UIView!
    @IBOutlet private(set) weak var trailingItemContainer: UIView!
    
    var viewModel: ShowcaseTableViewCellViewModel!
    
    var leadingItem: PanelViewItem!
    var trailingItem: PanelViewItem!
    /// Create a panel view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel) {
        self.viewModel = viewModel
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.leadingItem = PanelViewItem(on: self.leadingItemContainer, with: viewModel)
        self.trailingItem = PanelViewItem(on: self.trailingItemContainer, with: viewModel)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        removeObservers()
        leadingItem?.removeFromSuperview()
        trailingItem?.removeFromSuperview()
        leadingItem = nil
        trailingItem = nil
        viewModel = nil
    }
}

// MARK: - ViewProtocol Implementation

extension PanelView: ViewProtocol {
    fileprivate func viewDidConfigure() {
        playButton.layer.cornerRadius = 6.0
        playButton.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
    }
    
    @objc
    fileprivate func playDidTap() {
        /// Allocate a new detail controller.
        let coordinator = viewModel.coordinator!
        let section = viewModel.sectionAt(.display)
        let media = viewModel.presentedMedia.value!
        let rotated = true
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = rotated
        coordinator.coordinate(to: .detail)
    }
}

// MARK: - Observers

extension PanelView {
    func removeObservers() {
        printIfDebug(.success, "Removed `PanelView` observers.")
        leadingItem?.viewModel?.removeObservers()
        trailingItem?.viewModel.removeObservers()
    }
}

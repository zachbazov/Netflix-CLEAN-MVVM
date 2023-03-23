//
//  PanelView.swift
//  netflix
//
//  Created by Zach Bazov on 10/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var leadingItem: PanelViewItem! { get }
    var trailingItem: PanelViewItem! { get }
    
    func playDidTap()
}

// MARK: - PanelView Type

final class PanelView: View<ShowcaseTableViewCellViewModel> {
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private(set) weak var leadingItemContainer: UIView!
    @IBOutlet private(set) weak var trailingItemContainer: UIView!
    
    var leadingItem: PanelViewItem!
    var trailingItem: PanelViewItem!
    /// Create a panel view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.viewModel = viewModel
        self.constraintToSuperview(parent)
        self.leadingItem = PanelViewItem(on: self.leadingItemContainer, with: viewModel)
        self.trailingItem = PanelViewItem(on: self.trailingItemContainer, with: viewModel)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        leadingItem?.removeFromSuperview()
        trailingItem?.removeFromSuperview()
        leadingItem = nil
        trailingItem = nil
        viewModel = nil
    }
    
    override func viewDidConfigure() {
        playButton.layer.cornerRadius = 6.0
        playButton.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
    }
    
    override func viewDidUnbindObservers() {
        printIfDebug(.success, "Removed `PanelView` observers.")
        leadingItem?.viewDidUnbindObservers()
        trailingItem?.viewDidUnbindObservers()
    }
}

// MARK: - ViewInstantiable Implementation

extension PanelView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension PanelView: ViewProtocol {
    @objc
    fileprivate func playDidTap() {
        /// Allocate a new detail controller.
        let coordinator = viewModel.coordinator!
        let section = viewModel.sectionAt(.resumable)
        let media = viewModel.presentedMedia!
        let rotated = true
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = rotated
        coordinator.coordinate(to: .detail)
    }
}

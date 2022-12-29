//
//  DetailPanelView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailPanelView Type

final class DetailPanelView: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private weak var leadingViewContainer: UIView!
    @IBOutlet private weak var centerViewContainer: UIView!
    @IBOutlet private weak var trailingViewContainer: UIView!
    
    // MARK: Properties
    
    private(set) var leadingItem: DetailPanelViewItem!
    private(set) var centerItem: DetailPanelViewItem!
    private(set) var trailingItem: DetailPanelViewItem!
    
    // MARK: Initializer
    
    /// Create a panel view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.leadingItem = DetailPanelViewItem(on: self.leadingViewContainer, with: viewModel)
        self.centerItem = DetailPanelViewItem(on: self.centerViewContainer, with: viewModel)
        self.trailingItem = DetailPanelViewItem(on: self.trailingViewContainer, with: viewModel)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Deinitializer
    
    deinit {
        removeObservers()
        leadingItem.viewModel.removeObservers()
        centerItem.viewModel.removeObservers()
        trailingItem.viewModel.removeObservers()
        leadingItem.viewModel = nil
        centerItem.viewModel = nil
        trailingItem.viewModel = nil
        leadingItem = nil
        centerItem = nil
        trailingItem = nil
    }
}

// MARK: - UI Setup

extension DetailPanelView {
    private func viewDidConfigure() {
        backgroundColor = .black
    }
}

// MARK: - Observers

extension DetailPanelView {
    private func removeObservers() {
        printIfDebug("Removed `DetailPanelView` observers.")
        leadingItem?.viewModel?.removeObservers()
        centerItem?.viewModel?.removeObservers()
        trailingItem?.viewModel?.removeObservers()
    }
}

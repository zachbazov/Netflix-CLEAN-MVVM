//
//  DetailPanelView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var leadingItem: DetailPanelViewItem! { get }
    var centerItem: DetailPanelViewItem! { get }
    var trailingItem: DetailPanelViewItem! { get }
    
    func viewDidConfigure()
    func viewDidUnbindObservers()
}

// MARK: - DetailPanelView Type

final class DetailPanelView: UIView {
    @IBOutlet private weak var leadingViewContainer: UIView!
    @IBOutlet private weak var centerViewContainer: UIView!
    @IBOutlet private weak var trailingViewContainer: UIView!
    
    fileprivate(set) var leadingItem: DetailPanelViewItem!
    fileprivate(set) var centerItem: DetailPanelViewItem!
    fileprivate(set) var trailingItem: DetailPanelViewItem!
    
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
    
    deinit {
        viewDidUnbindObservers()
        leadingItem.viewModel = nil
        centerItem.viewModel = nil
        trailingItem.viewModel = nil
        leadingItem = nil
        centerItem = nil
        trailingItem = nil
    }
}

// MARK: - ViewInstantiable Implementation

extension DetailPanelView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension DetailPanelView: ViewProtocol {
    fileprivate func viewDidConfigure() {
        backgroundColor = .black
    }
    
    fileprivate func viewDidUnbindObservers() {
        printIfDebug(.success, "Removed `DetailPanelView` observers.")
        leadingItem.viewDidUnbindObservers()
        centerItem.viewDidUnbindObservers()
        trailingItem.viewDidUnbindObservers()
    }
}

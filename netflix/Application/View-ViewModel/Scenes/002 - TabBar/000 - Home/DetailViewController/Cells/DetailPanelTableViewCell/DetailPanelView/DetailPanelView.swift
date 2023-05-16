//
//  DetailPanelView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var leadingItem: DetailPanelViewItem? { get }
    var centerItem: DetailPanelViewItem? { get }
    var trailingItem: DetailPanelViewItem? { get }
}

// MARK: - DetailPanelView Type

final class DetailPanelView: UIView {
    @IBOutlet private weak var leadingViewContainer: UIView!
    @IBOutlet private weak var centerViewContainer: UIView!
    @IBOutlet private weak var trailingViewContainer: UIView!
    
    fileprivate(set) var leadingItem: DetailPanelViewItem?
    fileprivate(set) var centerItem: DetailPanelViewItem?
    fileprivate(set) var trailingItem: DetailPanelViewItem?
    
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
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewWillConfigure()
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.black)
    }
    
    func viewWillUnbindObservers() {
        guard let leadingItem = leadingItem,
              let centerItem = centerItem,
              let trailingItem = trailingItem
        else { return }
        
        leadingItem.viewWillUnbindObservers()
        centerItem.viewWillUnbindObservers()
        trailingItem.viewWillUnbindObservers()
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        leadingItem?.viewModel = nil
        centerItem?.viewModel = nil
        trailingItem?.viewModel = nil
        leadingItem = nil
        centerItem = nil
        trailingItem = nil
    }
}

// MARK: - ViewInstantiable Implementation

extension DetailPanelView: ViewInstantiable {}

// MARK: - ViewLifecycleBehavior Implementation

extension DetailPanelView: ViewLifecycleBehavior {}

// MARK: - ViewObserving Implementation

extension DetailPanelView: ViewObserving {}

// MARK: - ViewProtocol Implementation

extension DetailPanelView: ViewProtocol {}

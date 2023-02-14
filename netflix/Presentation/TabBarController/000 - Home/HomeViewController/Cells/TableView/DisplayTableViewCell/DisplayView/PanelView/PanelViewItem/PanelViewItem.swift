//
//  PanelViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - PanelViewItemConfiguration Type

final class PanelViewItemConfiguration {
    fileprivate weak var view: PanelViewItem?
    private var viewModel: DisplayTableViewCellViewModel
    private var gestureRecognizers: [GestureGecognizer]
    private var tapRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    /// Create a new panel view object.
    /// - Parameters:
    ///   - view: Instantiating view.
    ///   - gestureRecognizers: Gestures to activate.
    ///   - viewModel: Coordinating view model.
    init(view: PanelViewItem,
         gestureRecognizers: [GestureGecognizer],
         with viewModel: DisplayTableViewCellViewModel) {
        self.viewModel = viewModel
        self.view = view
        self.gestureRecognizers = gestureRecognizers
        self.viewDidRegisterRecognizers()
        self.viewDidConfigure()
    }
    
    deinit {
        view?.removeFromSuperview()
        view = nil
        tapRecognizer = nil
        longPressRecognizer = nil
    }
}

// MARK: - UI Setup

extension PanelViewItemConfiguration {
    /// Gesture representation type.
    enum GestureGecognizer {
        case tap
        case longPress
    }
    /// View representation type.
    enum Item: Int {
        case myList
        case info
    }
    
    private func viewDidRegisterRecognizers() {
        if gestureRecognizers.contains(.tap) {
            tapRecognizer = .init(target: self, action: #selector(viewDidTap))
            view?.addGestureRecognizer(tapRecognizer)
        }
        if gestureRecognizers.contains(.longPress) {
            longPressRecognizer = .init(target: self, action: #selector(viewDidLongPress))
            view?.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    private func selectIfNeeded() {
        guard let view = view,
              let item = Item(rawValue: view.tag) else {
            return
        }
        if case .myList = item {
            view.viewModel.isSelected.value = viewModel.myList.viewModel.contains(
                view.viewModel.media, in: viewModel.sectionAt(.myList).media)
        }
    }
    
    func viewDidConfigure() {
        guard let view = view, let viewModel = view.viewModel else { return }
        view.imageView.image = .init(systemName: viewModel.systemImage)
        view.titleLabel.text = viewModel.title
        
        selectIfNeeded()
    }
    
    @objc
    func viewDidTap() {
        guard let view = view,
              let tag = Item(rawValue: view.tag) else {
            return
        }
        switch tag {
        case .myList:
            /// Since, the tap event occurs from the `PanelViewItem`,
            /// the presenting view on the `DisplayView` is to be interacted.
            let media = viewModel.presentedMedia.value!
            // Add or remove the object from the list.
            viewModel.myList.viewModel.shouldAddOrRemove(media, uponSelection: view.viewModel.isSelected.value)
            // Reload browse overlay's collection data.
            viewModel.coordinator?.viewController?.browseOverlayView.collectionView.reloadData()
        case .info:
            // Allocate a new detail controller.
            let coordinator = viewModel.coordinator!
            let section = viewModel.sectionAt(.resumable)
            let media = viewModel.presentedMedia.value!
            coordinator.section = section
            coordinator.media = media
            coordinator.shouldScreenRotate = false
            coordinator.deploy(screen: .detail)
        }
        /// Set alpha animations for button as the event occurs.
        view.setAlphaAnimation(using: view.gestureRecognizers!.first) {
            view.viewModel.isSelected.value.toggle()
        }
    }
    
    @objc
    func viewDidLongPress() {}
}

// MARK: - PanelViewItem Type

final class PanelViewItem: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    // MARK: Type's Properties
    
    private(set) var configuration: PanelViewItemConfiguration!
    private(set) var viewModel: PanelViewItemViewModel!
    private(set) var isSelected = false
    
    // MARK: Initializer
    
    /// Create a panel view item object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DisplayTableViewCellViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.tag = parent.tag
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.viewModel = PanelViewItemViewModel(item: self, with: viewModel.presentedMedia.value!)
        self.configuration = PanelViewItemConfiguration(view: self, gestureRecognizers: [.tap], with: viewModel)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Deinitializer
    
    deinit {
        configuration.view = nil
        configuration = nil
        viewModel = nil
    }
}

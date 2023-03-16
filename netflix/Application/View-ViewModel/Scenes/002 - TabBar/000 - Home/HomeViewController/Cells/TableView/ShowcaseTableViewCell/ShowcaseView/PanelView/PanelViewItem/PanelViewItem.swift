//
//  PanelViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ConfigurationProtocol Type

private protocol ConfigurationOutput {
    var view: PanelViewItem? { get }
    var viewModel: ShowcaseTableViewCellViewModel { get }
    var gestureRecognizers: [PanelViewItemConfiguration.GestureGecognizer] { get }
    var tapRecognizer: UITapGestureRecognizer! { get }
    var longPressRecognizer: UILongPressGestureRecognizer! { get }
    
    func viewDidRegisterRecognizers()
    func selectIfNeeded()
    func viewDidUpdate()
    func viewDidTap()
    func viewDidLongPress()
}

private typealias ConfigurationProtocol = ConfigurationOutput

// MARK: - PanelViewItemConfiguration Type

final class PanelViewItemConfiguration {
    fileprivate weak var view: PanelViewItem?
    fileprivate var viewModel: ShowcaseTableViewCellViewModel
    fileprivate var gestureRecognizers: [GestureGecognizer]
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var longPressRecognizer: UILongPressGestureRecognizer!
    /// Create a new panel view object.
    /// - Parameters:
    ///   - view: Instantiating view.
    ///   - gestureRecognizers: Gestures to activate.
    ///   - viewModel: Coordinating view model.
    init(view: PanelViewItem,
         gestureRecognizers: [GestureGecognizer],
         with viewModel: ShowcaseTableViewCellViewModel) {
        self.viewModel = viewModel
        self.view = view
        self.gestureRecognizers = gestureRecognizers
        self.viewDidRegisterRecognizers()
        self.viewDidUpdate()
    }
    
    deinit {
        view?.removeFromSuperview()
        view = nil
        tapRecognizer = nil
        longPressRecognizer = nil
    }
}

// MARK: - GestureRecognizer Type

extension PanelViewItemConfiguration {
    /// Gesture representation type.
    enum GestureGecognizer {
        case tap
        case longPress
    }
}

// MARK: - Item Type

extension PanelViewItemConfiguration {
    /// View representation type.
    enum Item: Int {
        case myList
        case info
    }
}

// MARK: - ConfigurationProtocol Implementation

extension PanelViewItemConfiguration: ConfigurationProtocol {
    fileprivate func viewDidRegisterRecognizers() {
        if gestureRecognizers.contains(.tap) {
            tapRecognizer = .init(target: self, action: #selector(viewDidTap))
            view?.addGestureRecognizer(tapRecognizer)
        }
        if gestureRecognizers.contains(.longPress) {
            longPressRecognizer = .init(target: self, action: #selector(viewDidLongPress))
            view?.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    fileprivate func selectIfNeeded() {
        guard let view = view,
              let item = Item(rawValue: view.tag) else {
            return
        }
        if case .myList = item {
            view.viewModel.isSelected.value = viewModel.myList.viewModel.contains(
                view.viewModel.media, in: viewModel.sectionAt(.myList).media)
        }
    }
    
    func viewDidUpdate() {
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
            coordinator.coordinate(to: .detail)
        }
        /// Set alpha animations for button as the event occurs.
        view.setAlphaAnimation(using: view.gestureRecognizers!.first) {
            view.viewModel.isSelected.value.toggle()
        }
    }
    
    @objc
    func viewDidLongPress() {}
}

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var configuration: PanelViewItemConfiguration! { get }
    
    var isSelected: Bool { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - PanelViewItem Type

final class PanelViewItem: View<PanelViewItemViewModel> {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    private(set) var configuration: PanelViewItemConfiguration!
    private(set) var isSelected = false
    /// Create a panel view item object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        self.tag = parent.tag
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.viewModel = PanelViewItemViewModel(item: self, with: viewModel.presentedMedia.value!)
        self.configuration = PanelViewItemConfiguration(view: self, gestureRecognizers: [.tap], with: viewModel)
        self.viewDidBindObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        configuration.view = nil
        configuration = nil
        viewModel = nil
    }
    
    override func viewDidBindObservers() {
        viewModel.isSelected.observe(on: self) { [weak self] _ in
            guard let self = self else { return }
            self.configuration?.viewDidUpdate()
        }
    }
    
    override func viewDidUnbindObservers() {
        viewModel.isSelected.remove(observer: self)
    }
}

// MARK: - ViewInstantiable Implementation

extension PanelViewItem: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension PanelViewItem: ViewProtocol {}

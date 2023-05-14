//
//  DetailPanelViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - ConfigurationProtocol Type

private protocol ConfigurationProtocol {
    var view: DetailPanelViewItem! { get }
    var myList: MyList { get }
    var section: Section { get }
    
    func viewDidRegisterRecognizers()
    func viewDidConfigure()
    func selectIfNeeded()
    func viewDidTap()
}

// MARK: - DetailPanelViewItemConfiguration Type

final class DetailPanelViewItemConfiguration {
    fileprivate weak var view: DetailPanelViewItem!
    fileprivate let myList = MyList.shared
    fileprivate let section: Section
    
    deinit {
        view?.removeFromSuperview()
        view = nil
    }
    
    /// Create a panel view item configuration object.
    /// - Parameters:
    ///   - view: Corresponding view.
    ///   - viewModel: Coordinating view model.
    init(view: DetailPanelViewItem, with viewModel: DetailViewModel) {
        self.view = view
        
        self.section = myList.viewModel.section
        
        self.viewDidConfigure()
        self.viewDidRegisterRecognizers()
    }
}

// MARK: - ConfigurationProtocol Implementation

extension DetailPanelViewItemConfiguration: ConfigurationProtocol {
    fileprivate func viewDidRegisterRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    /// Change the view to `selected` state.
    /// Occurs while the `DisplayView` presenting media is contained in the user's list.
    fileprivate func selectIfNeeded() {
        guard let tag = Item(rawValue: view.tag) else { return }
        guard let viewModel = view.viewModel else { return }
        
        if case .myList = tag {
            let contains = myList.viewModel.contains(viewModel.media, in: section.media)
            viewModel.isSelected.value = contains
        }
    }
    
    func viewDidConfigure() {
        guard let viewModel = view.viewModel else { return }
        view.imageView.image = UIImage(systemName: viewModel.systemImage)?.whiteRendering()
        view.label.text = viewModel.title
        
        selectIfNeeded()
    }
    
    @objc
    func viewDidTap() {
        guard let tag = Item(rawValue: view.tag) else { return }
        guard let viewModel = view.viewModel else { return }
        switch tag {
        case .myList:
            let media = viewModel.media!
            
            myList.viewModel.shouldAddOrRemove(media, uponSelection: viewModel.isSelected.value)
            
            myList.viewModel.coordinator.viewController?.browseOverlayView?.collectionView.reloadData()
        case .rate: printIfDebug(.debug, "rate")
        case .share: printIfDebug(.debug, "share")
        }
        
        // Animate alpha effect.
        view.setAlphaAnimation(using: view.gestureRecognizers!.first) {
            viewModel.isSelected.value.toggle()
        }
    }
}

// MARK: - DetailPanelViewItemConfiguration.Item Type

extension DetailPanelViewItemConfiguration {
    /// Item representation type.
    enum Item: Int {
        case myList
        case rate
        case share
    }
}

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var configuration: DetailPanelViewItemConfiguration! { get }
    
    var imageView: UIImageView { get }
    var label: UILabel { get }
    
    var isSelected: Bool { get }
    
    func createLabel() -> UILabel
    func createImageView() -> UIImageView
}

// MARK: - DetailPanelViewItem Type

final class DetailPanelViewItem: View<DetailPanelViewItemViewModel> {
    fileprivate(set) var configuration: DetailPanelViewItemConfiguration!
    
    fileprivate lazy var imageView = createImageView()
    fileprivate lazy var label = createLabel()
    
    var isSelected = false
    /// Create a panel view item object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: parent.bounds)
        self.tag = parent.tag
        parent.addSubview(self)
        self.chainConstraintToCenter(linking: self.imageView, to: self.label)
        self.viewModel = DetailPanelViewItemViewModel(item: self, with: viewModel)
        self.configuration = DetailPanelViewItemConfiguration(view: self, with: viewModel)
        self.viewDidBindObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        configuration = nil
        viewModel = nil
    }
    
    override func viewDidBindObservers() {
        viewModel.isSelected.observe(on: self) { [weak self] _ in
            guard let self = self else { return }
            self.configuration?.viewDidConfigure()
        }
    }
    
    override func viewDidUnbindObservers() {
        if let viewModel = viewModel {
            viewModel.isSelected.remove(observer: self)
        }
    }
}

// MARK: - ViewProtocol Implementation

extension DetailPanelViewItem: ViewProtocol {
    fileprivate func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        label.textAlignment = .center
        addSubview(label)
        return label
    }
    
    fileprivate func createImageView() -> UIImageView {
        let image = UIImage()
        let imageView = UIImageView(image: image)
        imageView.image = image.whiteRendering()
        addSubview(imageView)
        return imageView
    }
}

//
//  DetailPanelViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var myList: MyList { get }
    
    var imageView: UIImageView { get }
    var label: UILabel { get }
    
    func createLabel() -> UILabel
    func createImageView() -> UIImageView
    
    func selectIfNeeded()
    func viewDidTap()
    
    func setTitle(_ title: String)
    func setImage(_ systemImage: String)
}

// MARK: - DetailPanelViewItem Type

final class DetailPanelViewItem: View<DetailPanelViewItemViewModel> {
    fileprivate let myList = MyList.shared
    
    fileprivate lazy var imageView = createImageView()
    fileprivate lazy var label = createLabel()
    
    private weak var parent: UIView?
    
    /// Create a panel view item object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        self.parent = parent
        
        super.init(frame: parent.bounds)
        
        self.tag = parent.tag
        
        self.viewModel = DetailPanelViewItemViewModel(item: self, with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillTargetSubviews()
        viewWillBindObservers()
    }
    
    override func viewHierarchyWillConfigure() {
        guard let parent = parent else { return }
        
        self.addToHierarchy(on: parent)
            .chainConstraintToCenter(linking: imageView, to: label)
    }
    
    override func viewWillTargetSubviews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        addGestureRecognizer(tapGesture)
    }
    
    override func viewWillBindObservers() {
        viewModel.isSelected.observe(on: self) { [weak self] _ in
            guard let self = self, let viewModel = self.viewModel else { return }
            
            self.setTitle(viewModel.title)
            self.setImage(viewModel.systemImage)
            self.selectIfNeeded()
        }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isSelected.remove(observer: self)
    }
    
    override func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        parent = nil
        viewModel = nil
        
        removeFromSuperview()
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
    
    /// Change the view to `selected` state.
    /// Occurs while the `DisplayView` presenting media is contained in the user's list.
    fileprivate func selectIfNeeded() {
        guard let tag = Item(rawValue: tag),
              let viewModel = viewModel
        else { return }
        
        if case .myList = tag {
            let media = myList.viewModel.section.media
            let contains = myList.viewModel.contains(viewModel.media, in: media)
            
            viewModel.isSelectedWillChange(contains)
        }
    }
    
    @objc
    func viewDidTap() {
        guard let tag = Item(rawValue: tag),
              let viewModel = viewModel,
              let homeController = myList.viewModel.coordinator.viewController
        else { return }
        
        switch tag {
        case .myList:
            let media = viewModel.media
            
            myList.viewModel.shouldAddOrRemove(media, uponSelection: viewModel.isSelected.value)
            
            homeController.browseOverlayView?.reloadData()
            homeController.tableView.reloadSection(at: .display)
        case .rate:
            printIfDebug(.debug, "rate")
        case .share:
            printIfDebug(.debug, "share")
        }
        
        setAlphaAnimation(using: gestureRecognizers!.first) {
            viewModel.isSelectedWillChange(!viewModel.isSelected.value)
        }
    }
    
    fileprivate func setTitle(_ title: String) {
        label.text = title
    }
    
    fileprivate func setImage(_ systemImage: String) {
        imageView.image = UIImage(systemName: systemImage)?.whiteRendering()
    }
}

// MARK: - Item Type

extension DetailPanelViewItem {
    /// Item representation type.
    enum Item: Int {
        case myList
        case rate
        case share
    }
}

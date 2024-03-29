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

final class DetailPanelViewItem: UIView, View {
    fileprivate let myList: MyList = Application.app.services.myList
    
    fileprivate lazy var imageView = createImageView()
    fileprivate lazy var label = createLabel()
    
    private weak var parent: UIView?
    
    var viewModel: DetailPanelViewItemViewModel!
    
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
    
    func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillTargetSubviews()
        viewWillBindObservers()
    }
    
    func viewHierarchyWillConfigure() {
        guard let parent = parent else { return }
        
        self.addToHierarchy(on: parent)
            .chainConstraintToCenter(linking: imageView, to: label)
    }
    
    func viewWillTargetSubviews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        addGestureRecognizer(tapGesture)
    }
    
    func viewWillBindObservers() {
        viewModel.isSelected.observe(on: self) { [weak self] _ in
            guard let self = self, let viewModel = self.viewModel else { return }
            
            self.setTitle(viewModel.title)
            self.setImage(viewModel.systemImage)
            self.selectIfNeeded()
        }
    }
    
    func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isSelected.remove(observer: self)
    }
    
    func viewWillDeallocate() {
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
              let viewModel = viewModel,
              let section = myList.section
        else { return }
        
        if case .myList = tag {
            let media = section.media
            let contains = myList.contains(viewModel.media, in: media)
            
            viewModel.isSelectedWillChange(contains)
        }
    }
    
    @objc
    func viewDidTap() {
        guard let tag = Item(rawValue: tag),
              let viewModel = viewModel,
              let homeController = Application.app.coordinator.tabCoordinator?.home?.viewControllers.first as? HomeViewController
        else { return }
        
        switch tag {
        case .myList:
            let media = viewModel.media
            
            myList.shouldAddOrRemove(media, uponSelection: viewModel.isSelected.value)
            
            homeController.browseOverlayView?.reloadData()
            homeController.tableView.reloadSection(at: .display)
        case .rate:
            printIfDebug(.debug, "rate")
        case .share:
            let text = "Netflix"
            var appConfiguration = Application.app.configuration
            let appURL = URL(string: appConfiguration.api.urlString)!
            let items: [Any] = [text, appURL]
            
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            
            if let popoverController = activityViewController.popoverPresentationController {
                
            }
            
            guard let controller = viewModel.coordinator.viewController else { return }
            controller.present(activityViewController, animated: true, completion: nil)
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

//
//  NotificationHybridCell.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import UIKit

// MARK: - NotificationHybridCell Type

final class NotificationHybridCell: UITableViewCell {
    lazy var collectionView: UICollectionView = createCollectionView()
    
    var cell: NotificationCollectionViewCell?
    var dataSource: NotificationCollectionViewDataSource?
    var viewModel: NotificationHybridCellViewModel?
    var controllerViewModel: MyNetflixViewModel?
    var layout: CollectionViewLayout?
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
        viewDidDeallocate()
    }
    
    override func prepareForReuse() {
        accessoryView = nil
        accessoryType = .none
        
        super.prepareForReuse()
    }
    
    func viewDidLoad() {
        viewHierarchyDidConfigure()
        viewDidDeploySubviews()
        viewDidConfigure()
    }
    
    func viewDidDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    func viewHierarchyDidConfigure() {
        collectionView
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewDidConfigure() {
//        setBackgroundColor(.hexColor("#121212"))
    }
    
    func viewDidDeallocate() {
        printIfDebug(.debug, "viewDidDeallocate")
        collectionView.removeFromSuperview()
        
        cell = nil
        dataSource = nil
        viewModel = nil
        controllerViewModel = nil
        layout = nil
        
        removeFromSuperview()
    }
}

// MARK: - HybridCell Implementation

extension NotificationHybridCell: HybridCell {}

// MARK: - Private Implementation

extension NotificationHybridCell {
    func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(NotificationCollectionViewCell.self)
        return collectionView
    }
    
    func createDataSource() {
        guard let controllerViewModel = controllerViewModel else { return }
        
        dataSource = NotificationCollectionViewDataSource(collectionView: collectionView, with: controllerViewModel)
    }
    
    func createLayout() {
        layout = CollectionViewLayout(layout: .notification, scrollDirection: .vertical)
        
        guard let layout = layout, let viewModel = viewModel else { fatalError() }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
//        prepareForReuse()
        
        dataSource?.dataSourceDidChange(at: [viewModel.indexPath])
    }
}




//    private func createNotificationIndicatorView() -> UIView {
//        let indicator = UIView(frame: .zero)
//        indicator.backgroundColor = .red
//        indicator.layer.cornerRadius = 4.0
//        return indicator
//    }

//    private func configureAccessoryView() {
//        guard let viewModel = viewModel,
//              let section = AccountTableViewDataSource.Section(rawValue: viewModel.indexPath.section),
//              let item = controllerViewModel?.menuItems[section.rawValue]
//        else { return }
//
//        let image = UIImage(
//            systemName: item.isExpanded ?? false ? "chevron.down" : "chevron.right")?
//            .withRenderingMode(.alwaysOriginal)
//            .withTintColor(.hexColor("b3b3b3"))
//
//        accessoryView = UIImageView(image: image)
//    }

//    private func configureIndicator() {
//        guard let viewModel = viewModel,
//              let section = AccountTableViewDataSource.Section(rawValue: viewModel.indexPath.section)
//        else { return }
//
//        switch section {
//        case .notifications:
//            guard viewModel.isFirstRow else { return }
//
//            notificationIndicator.addToHierarchy(on: contentView)
//
//            contentView.constraintToCenter(notificationIndicator, withLeadingAnchorValue: 6.0, sizeInPoints: 8.0)
//        default:
//            accessoryView = nil
//
//            notificationIndicator.removeFromSuperview()
//        }
//    }
//
//    private func setTitle(_ string: String) {
//        label.text = string
//    }



//        guard viewModel.isFirstRow else {
//            prepareForReuse()
//
//            collectionView
//                .addToHierarchy(on: contentView)
//                .constraintToSuperview(contentView)
//
//            dataSource?.dataSourceDidChange(at: [viewModel.indexPath])
//            return
//        }
//
//        dataSource = nil
//        collectionView.removeFromSuperview()


//    private func configureSections() {
//        guard let viewModel = viewModel,
//              let section = AccountTableViewDataSource.Section(rawValue: viewModel.indexPath.section)
//        else { return }
//
//        switch section {
//        case .notifications:
//            shouldAddOrRemoveCollectionView()
//        default: break
//        }
//    }

//
//  MediaNotificationHybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var label: UILabel { get }
    var image: UIImageView { get }
    var notificationIndicator: UIView { get }
}

// MARK: - MediaNotificationHybridCell Type

final class MediaNotificationHybridCell: HybridCell<NotificationCollectionViewCell, NotificationCollectionViewDataSource, MediaNotificationHybridCellViewModel, AccountViewModel> {
    lazy var label: UILabel = createTitleLabel()
    lazy var image: UIImageView = createImageView()
    lazy var notificationIndicator: UIView = createNotificationIndicatorView()
    
    deinit {
        viewWillDeallocate()
        super.viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        backgroundColor = .hexColor("#121212")
        
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        contentView.chainConstraintToSuperview(
            linking: image,
            to: label,
            withLeadingAnchorValue: 24.0,
            sizeInPoints: 28.0)
        
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    override func viewHierarchyWillConfigure() {
        
    }
    
    override func viewWillConfigure() {
        guard let viewModel = viewModel else { return }
        
        image.image = UIImage(systemName: viewModel.image)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#b3b3b3"))
        label.text = viewModel.title
        
        guard let item = controllerViewModel?.menuItems[viewModel.indexPath.section] else { return }
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: viewModel.indexPath.section) else { return }
        
        guard section == .notifications else {
            accessoryView = nil
            notificationIndicator.removeFromSuperview()
            return
        }
        
        guard viewModel.indexPath.row == .zero else {
            label.text = nil
            image.image = nil
            accessoryView = nil
            notificationIndicator.removeFromSuperview()
            
            contentView.addSubview(collectionView)
            collectionView.constraintToSuperview(contentView)
            
            setupDataSource()
            
            dataSource?.dataSourceDidChange(at: [viewModel.indexPath])
            return
        }
        
        collectionView.removeFromSuperview()
        
        label.text = item.title
        
        let image = UIImage(
            systemName: item.isExpanded ?? false ? "chevron.down" : "chevron.right")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("b3b3b3"))
        accessoryView = UIImageView(image: image)
        
        addNotificationIndicatorView()
    }
    
    override func viewWillDeallocate() {
        label.removeFromSuperview()
        image.removeFromSuperview()
        notificationIndicator.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewWillDeallocate()
        
        accessoryType = .none
        notificationIndicator.removeFromSuperview()
    }
    
    override func createCollectionView() -> UICollectionView {
        guard let layout = layout else { fatalError() }
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .hexColor("#121212")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(NotificationCollectionViewCell.self)
        return collectionView
    }
    
    override func createLayout() {
        layout = CollectionViewLayout(layout: .notification, scrollDirection: .vertical)
    }
}

// MARK: - ViewProtocol Implementation

extension MediaNotificationHybridCell: ViewProtocol {
    fileprivate func createImageView() -> UIImageView {
        let imageView = UIImageView(image: nil)
        return imageView
    }
    
    fileprivate func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .hexColor("#b3b3b3")
        return label
    }
    
    fileprivate func createNotificationIndicatorView() -> UIView {
        let indicator = UIView(frame: .zero)
        indicator.backgroundColor = .red
        indicator.layer.cornerRadius = 4.0
        return indicator
    }
}

// MARK: - Private Presentation Implementation

extension MediaNotificationHybridCell {
    private func setupDataSource() {
        guard let controllerViewModel = controllerViewModel else { return }
        
        dataSource = NotificationCollectionViewDataSource(collectionView: collectionView, with: controllerViewModel)
    }
    
    private func addNotificationIndicatorView() {
        contentView.addSubview(notificationIndicator)
        contentView.constraintToCenter(notificationIndicator, withLeadingAnchorValue: 6.0, sizeInPoints: 8.0)
    }
}

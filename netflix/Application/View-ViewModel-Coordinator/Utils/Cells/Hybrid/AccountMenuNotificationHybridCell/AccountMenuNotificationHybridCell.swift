//
//  AccountMenuNotificationHybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - AccountMenuNotificationHybridCell Type

final class AccountMenuNotificationHybridCell: UITableViewCell {
    lazy var label: UILabel = createTitleLabel()
    lazy var image: UIImageView = createImageView()
    lazy var notificationIndicator: UIView = createNotificationIndicatorView()
    lazy var collectionView: UICollectionView = createCollectionView()
    
    var cell: AccountMenuNotificationCollectionViewCell?
    var dataSource: AccountMenuNotificationCollectionViewDataSource?
    var viewModel: AccountMenuNotificationHybridCellViewModel?
    var controllerViewModel: AccountViewModel?
    var layout: CollectionViewLayout?
    
    deinit {
        viewWillDeallocate()
    }
    
    override func prepareForReuse() {
        label.text = nil
        image.image = nil
        accessoryView = nil
        accessoryType = .none
        
        super.prepareForReuse()
    }
}

// MARK: - HybridCell Implementation

extension AccountMenuNotificationHybridCell: HybridCell {
    func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    func viewHierarchyWillConfigure() {
        image.addToHierarchy(on: contentView)
        label.addToHierarchy(on: contentView)
        
        contentView
            .chainConstraintToSuperview(
                linking: image,
                to: label,
                withLeadingAnchorValue: 24.0,
                sizeInPoints: 28.0)
    }
    
    func viewWillConfigure() {
        guard let viewModel = viewModel else { return }
        
        setBackgroundColor(.hexColor("#121212"))
        setTitle(viewModel.title)
        
        configureImage()
        configureSections()
        configureIndicator()
    }
    
    func viewWillDeallocate() {
        label.removeFromSuperview()
        image.removeFromSuperview()
        notificationIndicator.removeFromSuperview()
        collectionView.removeFromSuperview()
        
        cell = nil
        dataSource = nil
        viewModel = nil
        controllerViewModel = nil
        layout = nil
        
        removeFromSuperview()
    }
    
    func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .hexColor("#121212")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(AccountMenuNotificationCollectionViewCell.self)
        return collectionView
    }
    
    func createDataSource() {
        guard let controllerViewModel = controllerViewModel else { return }
        
        dataSource = AccountMenuNotificationCollectionViewDataSource(collectionView: collectionView, with: controllerViewModel)
    }
    
    func createLayout() {
        layout = CollectionViewLayout(layout: .notification, scrollDirection: .vertical)
        
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

// MARK: - Private Implementation

extension AccountMenuNotificationHybridCell {
    private func createImageView() -> UIImageView {
        let imageView = UIImageView(image: nil)
        return imageView
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .hexColor("#b3b3b3")
        return label
    }
    
    private func createNotificationIndicatorView() -> UIView {
        let indicator = UIView(frame: .zero)
        indicator.backgroundColor = .red
        indicator.layer.cornerRadius = 4.0
        return indicator
    }
    
    private func configureImage() {
        guard let imageName = viewModel?.image,
              let systemImage = UIImage(systemName: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#b3b3b3"))
        else { return }
        
        self.image.image = systemImage
    }
    
    private func configureSections() {
        guard let viewModel = viewModel,
              let section = AccountMenuTableViewDataSource.Section(rawValue: viewModel.indexPath.section)
        else { return }
        
        switch section {
        case .notifications:
            configureAccessoryView()
            shouldAddOrRemoveCollectionView()
        default: break
        }
    }
    
    private func shouldAddOrRemoveCollectionView() {
        guard let viewModel = viewModel else { return }
        
        guard viewModel.isFirstRow else {
            prepareForReuse()
            
            collectionView
                .addToHierarchy(on: contentView)
                .constraintToSuperview(contentView)
            
            dataSource?.dataSourceDidChange(at: [viewModel.indexPath])
            return
        }
        
        dataSource = nil
        collectionView.removeFromSuperview()
    }
    
    private func configureAccessoryView() {
        guard let viewModel = viewModel,
              let section = AccountMenuTableViewDataSource.Section(rawValue: viewModel.indexPath.section),
              let item = controllerViewModel?.menuItems[section.rawValue]
        else { return }
        
        let image = UIImage(
            systemName: item.isExpanded ?? false ? "chevron.down" : "chevron.right")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("b3b3b3"))
        
        accessoryView = UIImageView(image: image)
    }
    
    private func configureIndicator() {
        guard let viewModel = viewModel,
              let section = AccountMenuTableViewDataSource.Section(rawValue: viewModel.indexPath.section)
        else { return }
        
        switch section {
        case .notifications:
            guard viewModel.isFirstRow else { return }
            
            notificationIndicator.addToHierarchy(on: contentView)
            
            contentView.constraintToCenter(notificationIndicator, withLeadingAnchorValue: 6.0, sizeInPoints: 8.0)
        default:
            accessoryView = nil
            
            notificationIndicator.removeFromSuperview()
        }
    }
    
    private func setTitle(_ string: String) {
        label.text = string
    }
}

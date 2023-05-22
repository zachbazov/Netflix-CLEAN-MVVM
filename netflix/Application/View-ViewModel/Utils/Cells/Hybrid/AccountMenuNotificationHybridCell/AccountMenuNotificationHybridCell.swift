//
//  AccountMenuNotificationHybridCell.swift
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
    
    func setTitle(_ string: String)
}

// MARK: - AccountMenuNotificationHybridCell Type

final class AccountMenuNotificationHybridCell: HybridCell<AccountMenuNotificationCollectionViewCell, AccountMenuNotificationCollectionViewDataSource, AccountMenuNotificationHybridCellViewModel, AccountViewModel> {
    lazy var label: UILabel = createTitleLabel()
    lazy var image: UIImageView = createImageView()
    lazy var notificationIndicator: UIView = createNotificationIndicatorView()
    
    deinit {
        viewWillDeallocate()
        super.viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    override func viewHierarchyWillConfigure() {
        image.addToHierarchy(on: contentView)
        label.addToHierarchy(on: contentView)
        
        contentView
            .chainConstraintToSuperview(
                linking: image,
                to: label,
                withLeadingAnchorValue: 24.0,
                sizeInPoints: 28.0)
    }
    
    override func viewWillConfigure() {
        guard let viewModel = viewModel else { return }
        
        setBackgroundColor(.hexColor("#121212"))
        setTitle(viewModel.title)
        
        configureImage()
        configureSections()
        configureIndicator()
    }
    
    override func viewWillDeallocate() {
        label.removeFromSuperview()
        image.removeFromSuperview()
        notificationIndicator.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
        image.image = nil
        accessoryView = nil
        accessoryType = .none
    }
    
    override func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .hexColor("#121212")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(AccountMenuNotificationCollectionViewCell.self)
        return collectionView
    }
    
    override func createDataSource() {
        guard let controllerViewModel = controllerViewModel else { return }
        
        dataSource = AccountMenuNotificationCollectionViewDataSource(collectionView: collectionView, with: controllerViewModel)
    }
    
    override func createLayout() {
        layout = CollectionViewLayout(layout: .notification, scrollDirection: .vertical)
        
        guard let layout = layout else { return }
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

// MARK: - ViewProtocol Implementation

extension AccountMenuNotificationHybridCell: ViewProtocol {
    fileprivate func setTitle(_ string: String) {
        label.text = string
    }
}

// MARK: - Private Presentation Implementation

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
}

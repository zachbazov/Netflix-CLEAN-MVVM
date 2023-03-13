//
//  AccountMenuTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: AccountMenuTableViewCellViewModel)
    func viewDidConfigure(at indexPath: IndexPath)
}

private protocol ViewOutput {
    var collectionView: UICollectionView { get }
    var dataSource: NotificationCollectionViewDataSource! { get }
    var layout: CollectionViewLayout! { get }
    
    var label: UILabel? { get }
    var image: UIImageView? { get }
    var notificationIndicator: UIView? { get }
    
    func createCollectionView() -> UICollectionView
    func createImageView() -> UIImageView
    func createTitleLabel() -> UILabel
    func createNotificationIndicatorView() -> UIView
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - AccountMenuTableViewCell Type

final class AccountMenuTableViewCell: UITableViewCell {
    private var viewModel: AccountViewModel?
    
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: NotificationCollectionViewDataSource!
    fileprivate var layout: CollectionViewLayout!
    
    lazy var label: UILabel? = createTitleLabel()
    lazy var image: UIImageView? = createImageView()
    lazy var notificationIndicator: UIView? = createNotificationIndicatorView()
    
    static func create(in tableView: UITableView,
                       at indexPath: IndexPath,
                       with viewModel: AccountViewModel) -> AccountMenuTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AccountMenuTableViewCell.reuseIdentifier,
            for: indexPath) as? AccountMenuTableViewCell else { fatalError() }
        cell.viewModel = viewModel
        let model = viewModel.menuItems[indexPath.section]
        let cellViewModel = AccountMenuTableViewCellViewModel(with: model)
        cell.viewDidLoad()
        cell.viewDidConfigure(with: cellViewModel)
        cell.viewDidConfigure(at: indexPath)
        return cell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        notificationIndicator?.removeFromSuperview()
    }
    
    func viewDidLoad() {
        guard let image = image, let label = label else { return }
        
        backgroundColor = .hexColor("#121212")
        
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        contentView.chainConstraintToSuperview(
            linking: image,
            to: label,
            withLeadingAnchorValue: 24.0,
            sizeInPoints: 28.0)
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension AccountMenuTableViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension AccountMenuTableViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(at indexPath: IndexPath) {
        guard let item = viewModel?.menuItems[indexPath.section] else { return }
        guard let section = AccountMenuTableViewDataSource.Section(rawValue: indexPath.section) else { return }
        
        guard section == .notifications else {
            accessoryView = nil
            notificationIndicator?.removeFromSuperview()
            return
        }
        
        guard indexPath.row == .zero else {
            label?.text = nil
            image?.image = nil
            accessoryView = nil
            notificationIndicator?.removeFromSuperview()
            
            contentView.addSubview(collectionView)
            collectionView.constraintToSuperview(contentView)
            
            setupDataSource()
            
            dataSource.dataSourceDidChange(at: [indexPath])
            return
        }
        
        collectionView.removeFromSuperview()
        
        label?.text = item.title
        
        let image = UIImage(
            systemName: item.isExpanded ?? false ? "chevron.down" : "chevron.right")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("b3b3b3"))
        accessoryView = UIImageView(image: image)
        
        addNotificationIndicatorView()
    }
    
    fileprivate func viewDidConfigure(with viewModel: AccountMenuTableViewCellViewModel) {
        image?.image = UIImage(systemName: viewModel.image)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#b3b3b3"))
        label?.text = viewModel.title
    }
    
    fileprivate func createCollectionView() -> UICollectionView {
        layout = CollectionViewLayout(layout: .notification, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .hexColor("#121212")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(NotificationCollectionViewCell.self)
        contentView.addSubview(collectionView)
        collectionView.constraintToSuperview(contentView)
        return collectionView
    }
    
    fileprivate func createImageView() -> UIImageView {
        let image = UIImage()
        let imageView = UIImageView(image: image)
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

// MARK: - Private UI Implementation

extension AccountMenuTableViewCell {
    private func setupDataSource() {
        dataSource = NotificationCollectionViewDataSource(collectionView: collectionView, with: viewModel!)
    }
    
    private func addNotificationIndicatorView() {
        contentView.addSubview(notificationIndicator!)
        contentView.constraintToCenter(notificationIndicator!, withLeadingAnchorValue: 6.0, sizeInPoints: 8.0)
    }
}

//
//  AccountMenuTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

final class AccountMenuTableViewCell: UITableViewCell {
    lazy var label: UILabel? = createTitleLabel()
    lazy var image: UIImageView? = createImageView()
    lazy var notificationIndicator: UIView? = createNotificationIndicatorView()
    
    private var viewModel: AccountViewModel?
    
    private lazy var collectionView: UICollectionView = createCollectionView()
    private var dataSource: NotificationCollectionViewDataSource!
    private var layout: CollectionViewLayout!
    
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
        
        image.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0),
            image.widthAnchor.constraint(equalToConstant: 28.0),
            image.heightAnchor.constraint(equalToConstant: 28.0),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8.0),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func viewDidConfigure(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                label?.text = viewModel?.menuItems[indexPath.section].title ?? ""
                
                if viewModel?.menuItems[indexPath.section].isExpanded ?? false {
                    let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.hexColor("b3b3b3"))
                    accessoryView = UIImageView(image: image)
                } else {
                    let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.hexColor("b3b3b3"))
                    accessoryView = UIImageView(image: image)
                }
                
                collectionView.isHidden(true)
                
                contentView.addSubview(notificationIndicator!)
                
                notificationIndicator?.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    notificationIndicator!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6.0),
                    notificationIndicator!.widthAnchor.constraint(equalToConstant: 8.0),
                    notificationIndicator!.heightAnchor.constraint(equalToConstant: 8.0),
                    notificationIndicator!.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
                ])
            } else {
                label?.text = nil
                accessoryView = nil
                image?.image = nil
                notificationIndicator?.removeFromSuperview()
                
                collectionView.isHidden(false)
                
                dataSource = NotificationCollectionViewDataSource(collectionView: collectionView, with: viewModel!)
                
                collectionView.delegate = dataSource
                collectionView.dataSource = dataSource
                collectionView.reloadItems(at: [indexPath])
            }
        } else {
            accessoryView = nil
            notificationIndicator?.removeFromSuperview()
        }
    }
    
    func viewDidConfigure(with viewModel: AccountMenuTableViewCellViewModel) {
        image?.image = .init(systemName: viewModel.image)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#b3b3b3"))
        label?.text = viewModel.title
    }
    
    private func createImageView() -> UIImageView? {
        let image = UIImage()
        let imageView = UIImageView(image: image)
        return imageView
    }
    
    private func createTitleLabel() -> UILabel? {
        let label = UILabel()
        label.textColor = .hexColor("#b3b3b3")
        return label
    }
    
    private func createNotificationIndicatorView() -> UIView? {
        let indicator = UIView(frame: .zero)
        indicator.backgroundColor = .red
        indicator.layer.cornerRadius = 4.0
        return indicator
    }
}

extension AccountMenuTableViewCell: ViewLifecycleBehavior {}

extension AccountMenuTableViewCell {
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
}

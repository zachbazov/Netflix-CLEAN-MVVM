//
//  AccountMenuTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

final class AccountMenuTableViewCell: UITableViewCell {
    private lazy var label: UILabel? = createTitleLabel()
    private lazy var image: UIImageView? = createImageView()
    
    private var viewModel: AccountViewModel?
    
    static func create(in tableView: UITableView,
                       at indexPath: IndexPath,
                       with viewModel: AccountViewModel) -> AccountMenuTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AccountMenuTableViewCell.reuseIdentifier,
            for: indexPath) as? AccountMenuTableViewCell else { fatalError() }
        cell.viewModel = viewModel
        cell.viewDidLoad()
        let model = viewModel.menuItems[indexPath.section]
        let cellViewModel = AccountMenuTableViewCellViewModel(with: model)
        cell.viewDidConfigure(with: cellViewModel)
        return cell
    }
    
    func viewDidLoad() {
        guard let image = image, let label = label else { return }
        
        backgroundColor = .hexColor("#121212")
        accessoryType = .disclosureIndicator
        
        image.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(image)
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            image.widthAnchor.constraint(equalToConstant: 28.0),
            image.heightAnchor.constraint(equalToConstant: 28.0),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8.0),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
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
}

extension AccountMenuTableViewCell: ViewLifecycleBehavior {}

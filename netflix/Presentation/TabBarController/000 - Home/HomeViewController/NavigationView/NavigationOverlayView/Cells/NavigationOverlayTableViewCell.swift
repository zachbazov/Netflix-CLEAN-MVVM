//
//  NavigationOverlayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

final class NavigationOverlayTableViewCell: UITableViewCell {
    private lazy var titleLabel = createLabel()
    /// Create and dequeue a navigation overlay table view cell.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A navigation overlay table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: NavigationOverlayViewModel) -> NavigationOverlayTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NavigationOverlayTableViewCell.reuseIdentifier,
            for: indexPath) as? NavigationOverlayTableViewCell else {
            fatalError()
        }
        let model = viewModel.items.value[indexPath.row]
        let viewModel = NavigationOverlayCollectionViewCellViewModel(title: model.stringValue)
        cell.setupSubviews()
        cell.viewDidConfigure(with: viewModel)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension NavigationOverlayTableViewCell {
    private func setupSubviews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: .init(x: .zero, y: .zero,
                                         width: UIScreen.main.bounds.width, height: 44.0))
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        addSubview(label)
        return label
    }
    
    private func viewDidConfigure(with viewModel: NavigationOverlayCollectionViewCellViewModel) {
        titleLabel.text = viewModel.title
    }
}

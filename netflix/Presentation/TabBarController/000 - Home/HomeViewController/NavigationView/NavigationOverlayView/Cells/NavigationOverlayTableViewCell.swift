//
//  NavigationOverlayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

final class NavigationOverlayTableViewCell: UITableViewCell {
    private lazy var titleLabel = createLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
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
        cell.applyConfig(with: viewModel)
        return cell
    }
    
    private func viewDidConfigure() {
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
}

extension NavigationOverlayTableViewCell {
    private func applyConfig(with viewModel: NavigationOverlayCollectionViewCellViewModel) {
        titleLabel.text = viewModel.title
    }
}

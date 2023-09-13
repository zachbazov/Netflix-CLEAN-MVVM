//
//  ReferrableTableHeaderView.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import UIKit

// MARK: - ReferrableTableHeaderView Type

final class ReferrableTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var imageViewContainer: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accessoryImageView: UIImageView!
    
    var viewModel: ReferrableTableHeaderViewModel!
    
    var index: Int?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TableViewHeader Implementation

extension ReferrableTableHeaderView: TableViewHeader {
    func viewDidLoad() {
        viewDidTargetSubviews()
        viewDidConfigure()
    }
    
    func viewDidTargetSubviews() {
        addTapGesture(self, action: #selector(didSelect))
    }
    
    func viewDidConfigure() {
        setTitle(viewModel.title)
        setImage(viewModel.image)
        setImageBackgroundColor(viewModel.imageBackgroundColor)
        setAccessoryImage(viewModel.accessoryImage)
        setAccessoryViewHidden(viewModel.hasAccessory)
        setCornerRadius(imageViewContainer)
        setImageHidden(viewModel.hasImage)
    }
    
    func setTitle(_ string: String) {
        titleLabel.text = string
    }
    
    func setImage(_ systemName: String) {
        let image = UIImage(systemName: systemName)?.whiteRendering()
        imageView.image = image
    }
    
    func setImageBackgroundColor(_ color: Color) {
        imageViewContainer.backgroundColor = color.uiColor
    }
    
    func setAccessoryImage(_ systemName: String) {
        let configuration = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: systemName)?.whiteRendering(with: configuration)
        accessoryImageView.image = image
    }
    
    func setCornerRadius(_ view: UIView) {
        view.cornerRadius(view.bounds.height / 2)
    }
    
    func setImageHidden(_ hidden: Bool) {
        imageViewContainer.hidden(!hidden)
    }
    
    func setAccessoryViewHidden(_ hidden: Bool) {
        accessoryImageView.hidden(!hidden)
    }
}

// MARK: - ViewInstantiable Implementation

extension ReferrableTableHeaderView: ViewInstantiable {}

// MARK: - Private Implementation

extension ReferrableTableHeaderView {
    @objc
    private func didSelect() {
        guard let index = index,
              let section = AccountTableViewDataSource.Section(rawValue: index)
        else { return }
        
        switch section {
        case .profile:
            break
        case .notifications:
            viewModel.coordinator.coordinate(to: .notifications)
        case .downloads:
            viewModel.coordinator.coordinate(to: .downloads)
        case .myList:
            viewModel.coordinator.coordinate(to: .myList)
        case .trailersWatched:
            break
        }
    }
}

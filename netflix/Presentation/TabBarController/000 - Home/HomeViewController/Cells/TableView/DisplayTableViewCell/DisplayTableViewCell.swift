//
//  DisplayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

final class DisplayTableViewCell: UITableViewCell {
    let displayView: DisplayView
    private let viewModel: DisplayTableViewCellViewModel
    
    init(for indexPath: IndexPath, with viewModel: HomeViewModel) {
        self.viewModel = DisplayTableViewCellViewModel(with: viewModel)
        let displayView = DisplayView(with: self.viewModel)
        self.displayView = displayView
        super.init(style: .default, reuseIdentifier: DisplayTableViewCell.reuseIdentifier)
        self.contentView.addSubview(self.displayView)
        self.displayView.constraintToSuperview(self.contentView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
//    deinit {
//        displayView.removeFromSuperview()
//    }
    
    func terminate() {
        storeDisplayCacheBeforeReallocation()
    }
}

extension DisplayTableViewCell {
    private func storeDisplayCacheBeforeReallocation() {
        let tabViewModel = Application.current.rootCoordinator.tabViewModel
        let homeViewModel = viewModel.coordinator!.viewController!.viewModel!
        tabViewModel?.latestDisplayCache = homeViewModel.displayMediaCache
    }
}

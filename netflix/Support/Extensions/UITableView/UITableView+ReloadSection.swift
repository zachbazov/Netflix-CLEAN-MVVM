//
//  UITableView+ReloadSection.swift
//  netflix
//
//  Created by Zach Bazov on 16/05/2023.
//

import UIKit.UITableView

// MARK: - Reload Section by Index

extension UITableView {
    func reloadSection(at index: HomeTableViewDataSource.Index, with animation: RowAnimation = .automatic) {
        guard let index = HomeTableViewDataSource.Index(rawValue: index.rawValue) else { return }
        
        let indexSet = IndexSet(integer: index.rawValue)
        
        reloadSections(indexSet, with: animation)
    }
}

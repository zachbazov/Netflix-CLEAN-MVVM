//
//  UITableView+ReloadSection.swift
//  netflix
//
//  Created by Zach Bazov on 16/05/2023.
//

import UIKit.UITableView

// MARK: - Reload Section by Index

extension UITableView {
    func reloadSection(at index: MediaTableViewDataSource.Index, with animation: RowAnimation = .automatic) {
        guard let index = MediaTableViewDataSource.Index(rawValue: index.rawValue) else { return }
        
        let indexSet = IndexSet(integer: index.rawValue)
        
        reloadSections(indexSet, with: animation)
    }
}

//
//  UITableView+ContentInset.swift
//  netflix
//
//  Created by Zach Bazov on 22/12/2022.
//

import UIKit.UITableView

// MARK: - UITableView + ContentInset

extension UITableView {
    func centerVertically(on parent: UIView) {
        let navigationOverlayFooterHeight = CGFloat(80.0)
        
        contentInset = UIEdgeInsets(
            top: (parent.bounds.height - contentSize.height) / 4.0 + navigationOverlayFooterHeight,
            left: .zero,
            bottom: (parent.bounds.height - contentSize.height) / 4.0,
            right: .zero)
    }
}

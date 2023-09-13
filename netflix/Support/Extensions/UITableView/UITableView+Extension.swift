//
//  UITableView+Extension.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import UIKit.UITableView

// MARK: - Constants

extension UITableView {
    static var reusableViewPointSize: CGFloat = 1.0
    
    static var spacerPointSize: CGFloat = 8.0
}

// MARK: - Dummy View

extension UITableView {
    static var dummyView: UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
}

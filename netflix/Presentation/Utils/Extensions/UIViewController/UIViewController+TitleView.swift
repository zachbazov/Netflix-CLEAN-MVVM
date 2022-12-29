//
//  UIViewController+TitleView.swift
//  netflix
//
//  Created by Zach Bazov on 29/12/2022.
//

import UIKit

// MARK: - UIViewController + TitleView

extension UIViewController {
    func addNavigationItemTitleView() {
        let asset = "netflix-logo-2"
        
        let point = CGPoint(x: 0.0, y: 0.0)
        let size = CGSize(width: 80.0, height: 24.0)
        let rect = CGRect(origin: point, size: size)
        
        let titleView = UIView(frame: rect)
        let image = UIImage(named: asset)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        imageView.center = CGPoint(x: titleView.center.x, y: titleView.center.y)
        
        titleView.addSubview(imageView)
        navigationItem.titleView = titleView
    }
}

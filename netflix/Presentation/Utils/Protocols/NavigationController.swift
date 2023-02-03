//
//  NavigationController.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit.UINavigationController

// MARK: - NavigationController Type

class NavigationController: UINavigationController {
    weak var progress: UIProgressView!
    
    var isProgressHidden: Bool = true {
        didSet { setupProgress() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
}

// MARK: - UI Setup

extension NavigationController {
    private func setupSubviews() {
        navigationBar.prefersLargeTitles = false
        navigationBar.barStyle = .black
        navigationBar.tintColor = .white
    }
}

// MARK: - Methods

extension NavigationController {
    private func setupProgress() {
        if isProgressHidden {
            if progress != nil {
                progress.removeFromSuperview()
                updateViewConstraints()
            }
        } else {
            let progress = UIProgressView(progressViewStyle: .bar)
            progress.translatesAutoresizingMaskIntoConstraints = false
            progress.progress = 0
            progress.backgroundColor = .black
            navigationBar.addSubview(progress)
            NSLayoutConstraint.activate([
                progress.heightAnchor.constraint(equalToConstant: 5),
                progress.leftAnchor.constraint(equalTo: navigationBar.leftAnchor),
                progress.rightAnchor.constraint(equalTo: navigationBar.rightAnchor),
                progress.topAnchor.constraint(equalTo: navigationBar.bottomAnchor)
                ])
            self.progress = progress
        }
    }
}

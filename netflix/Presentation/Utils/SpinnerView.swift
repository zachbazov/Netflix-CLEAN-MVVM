//
//  SpinnerView.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit

// MARK: - SpinnerView Type

final class SpinnerView {
    static var spinner: UIActivityIndicatorView?
}

// MARK: - Methods

extension SpinnerView {
    static func show() {
        asynchrony {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(update),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)
            if spinner == nil, let window = Application.current.rootCoordinator.window {
                let frame = UIScreen.main.bounds
                let spinner = UIActivityIndicatorView(frame: frame)
                spinner.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                spinner.style = UIActivityIndicatorView.Style.large
                window.addSubview(spinner)

                spinner.startAnimating()
                self.spinner = spinner
            }
        }
    }

    static func hide() {
        asynchrony {
            guard let spinner = spinner else { return }
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self.spinner = nil
        }
    }

    @objc
    static func update() {
        asynchrony {
            if spinner != nil {
                hide()
                show()
            }
        }
    }
}

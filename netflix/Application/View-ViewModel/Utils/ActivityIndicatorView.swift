//
//  SpinnerView.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit

// MARK: - IndicatorProtocol Type

private protocol IndicatorProtocol {
    static var indicator: UIActivityIndicatorView? { get }
    
    static func viewDidShow()
    static func viewDidHide()
    static func viewDidUpdate()
}

// MARK: - ActivityIndicatorView Type

final class ActivityIndicatorView {
    static var indicator: UIActivityIndicatorView?
}

// MARK: - IndicatorProtocol Implementation

extension ActivityIndicatorView: IndicatorProtocol {
    static func viewDidShow() {
        mainQueueDispatch {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(viewDidUpdate),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)
            if indicator == nil,
               let window = Application.app.coordinator.window {
                let frame = UIScreen.main.bounds
                let spinner = UIActivityIndicatorView(frame: frame)
                spinner.backgroundColor = UIColor.black.withAlphaComponent(0.25)
                spinner.style = UIActivityIndicatorView.Style.large
                window.addSubview(spinner)

                spinner.startAnimating()
                self.indicator = spinner
            }
        }
    }

    static func viewDidHide() {
        mainQueueDispatch {
            guard let spinner = indicator else { return }
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self.indicator = nil
        }
    }

    @objc
    static func viewDidUpdate() {
        mainQueueDispatch {
            if indicator != nil {
                viewDidHide()
                viewDidShow()
            }
        }
    }
}

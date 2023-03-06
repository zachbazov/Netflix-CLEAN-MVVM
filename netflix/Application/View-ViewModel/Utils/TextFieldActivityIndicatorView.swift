//
//  TextFieldActivityIndicatorView.swift
//  netflix
//
//  Created by Zach Bazov on 06/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var textField: UITextField? { get }
    var indicatorView: UIActivityIndicatorView? { get }
    var isLoading: Bool { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - TextFieldActivityIndicatorView Type

final class TextFieldActivityIndicatorView {
    var textField: UITextField?
    
    var indicatorView: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return indicatorView != nil
        }
        set {
            if newValue {
                if indicatorView == nil {
                    let newActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
                    newActivityIndicator.color = UIColor.gray
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = textField?.backgroundColor ?? UIColor.black
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? .zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width / 2, y: leftViewSize.height / 2)
                }
            } else {
                indicatorView?.removeFromSuperview()
            }
        }
    }
    
    required init(textField: UITextField?) {
        self.textField = textField
    }
}

// MARK: - ViewProtocol Implementation

extension TextFieldActivityIndicatorView: ViewProtocol {}

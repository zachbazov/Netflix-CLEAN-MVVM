//
//  HDView.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var label: UILabel { get }
    
    func createLabel() -> UILabel
    func viewDidConfigure()
}

private typealias ViewProtocol = ViewOutput

// MARK: - HDView Type

final class HDView: UIView {
    fileprivate lazy var label = createLabel()
    /// Create an HD view object.
    /// - Parameter parent: Instantiating view.
    init(on parent: UIView) {
        super.init(frame: parent.bounds)
        parent.addSubview(self)
        self.addSubview(self.label)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewProtocol Implementation

extension HDView: ViewProtocol {
    fileprivate func viewDidConfigure() {
        layer.cornerRadius = 2.0
        backgroundColor = .hexColor("#414141")
    }
    
    fileprivate func createLabel() -> UILabel {
        let label = UILabel(frame: bounds)
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "HD"
        return label
    }
}

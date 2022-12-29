//
//  HDView.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - HDView Type

final class HDView: UIView {
    
    // MARK: Properties
    
    private lazy var label = createLabel()
    
    // MARK: Initializer
    
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

// MARK: - UI Setup

extension HDView {
    private func viewDidConfigure() {
        layer.cornerRadius = 2.0
        backgroundColor = .hexColor("#414141")
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: bounds)
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "HD"
        return label
    }
}

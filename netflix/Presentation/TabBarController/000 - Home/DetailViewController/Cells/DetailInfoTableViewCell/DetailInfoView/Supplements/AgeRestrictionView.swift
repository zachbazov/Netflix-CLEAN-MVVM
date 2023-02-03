//
//  AgeRestrictionView.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - AgeRestrictionView Type

final class AgeRestrictionView: UIView {
    private lazy var label = createLabel()
    /// Create an age restriction view object.
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

extension AgeRestrictionView {
    private func viewDidConfigure() {
        layer.cornerRadius = 2.0
        backgroundColor = .hexColor("#535353")
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: bounds)
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "PG-13"
        return label
    }
}

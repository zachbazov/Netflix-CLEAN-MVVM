//
//  AgeRestrictionView.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var label: UILabel { get }
    
    func createLabel() -> UILabel
}

// MARK: - AgeRestrictionView Type

final class AgeRestrictionView: UIView {
    fileprivate lazy var label = createLabel()
    
    /// Create an age restriction view object.
    /// - Parameter parent: Instantiating view.
    init(on parent: UIView) {
        super.init(frame: .zero)
        
        self.viewDidLoad(on: parent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func viewDidLoad(on parent: UIView) {
        viewHierarchyWillConfigure(on: parent)
        viewWillConfigure()
    }
    
    func viewHierarchyWillConfigure(on parent: UIView) {
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
        
        label
            .addToHierarchy(on: self)
            .constraintToSuperview(self)
    }
    
    func viewWillConfigure() {
        layer.cornerRadius = 2.0
        setBackgroundColor(.hexColor("#535353"))
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension AgeRestrictionView: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension AgeRestrictionView: ViewProtocol {
    fileprivate func createLabel() -> UILabel {
        let label = UILabel(frame: bounds)
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "PG-13"
        return label
    }
}

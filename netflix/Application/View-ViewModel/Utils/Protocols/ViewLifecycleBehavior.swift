//
//  ViewLifecycleBehavior.swift
//  netflix
//
//  Created by Zach Bazov on 20/02/2023.
//

import Foundation

// MARK: - ViewLifecycleBehavior Type

protocol ViewLifecycleBehavior {
    func viewDidLoad()
    func viewDidLoadBehaviors()
    func viewDidDeploySubviews()
    func viewHierarchyDidConfigure()
    func viewDidConfigure()
    func viewDidTargetSubviews()
    func viewWillAppear()
    func viewWillDisappear()
    func viewWillAnimateAppearance()
    func viewWillAnimateDisappearance()
    func viewShouldAppear(_ presented: Bool)
    func viewWillDeallocate()
    func viewDidDeallocate()
    
    func prepareForReuse()
}

// MARK: - Default Implementation

extension ViewLifecycleBehavior {
    func viewDidLoad() {}
    func viewDidLoadBehaviors() {}
    func viewDidDeploySubviews() {}
    func viewHierarchyDidConfigure() {}
    func viewDidConfigure() {}
    func viewDidTargetSubviews() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewWillAnimateAppearance() {}
    func viewWillAnimateDisappearance() {}
    func viewShouldAppear(_ presented: Bool) {}
    func viewWillDeallocate() {}
    func viewDidDeallocate() {}
    
    func prepareForReuse() {}
}

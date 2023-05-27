//
//  ViewLifecycleBehavior.swift
//  netflix
//
//  Created by Zach Bazov on 20/02/2023.
//

import Foundation

// MARK: - ViewLifecycleBehavior Type

protocol ViewLifecycleBehavior {
    func viewWillLoad()
    func viewDidLoad()
    func viewWillLoadBehaviors()
    func viewDidLoadBehaviors()
    func viewWillDeploySubviews()
    func viewDidDeploySubviews()
    func viewHierarchyWillConfigure()
    func viewHierarchyDidConfigure()
    func viewWillConfigure()
    func viewDidConfigure()
    func viewWillTargetSubviews()
    func viewDidTargetSubviews()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()
    func viewWillDeallocate()
    func viewDidDeallocate()
    
    func viewWillAnimateAppearance()
    func viewDidAnimateAppearance()
    func viewWillAnimateDisappearance()
    func viewDidAnimateDisappearance()
    func viewShouldAppear(_ presented: Bool)
}

// MARK: - Default Implementation

extension ViewLifecycleBehavior {
    func dataWillLoad() {}
    func dataDidLoad() {}
    
    func viewWillLoad() {}
    func viewDidLoad() {}
    func viewWillLoadBehaviors() {}
    func viewDidLoadBehaviors() {}
    func viewWillDeploySubviews() {}
    func viewDidDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewHierarchyDidConfigure() {}
    func viewWillConfigure() {}
    func viewDidConfigure() {}
    func viewWillTargetSubviews() {}
    func viewDidTargetSubviews() {}
    func viewWillAppear() {}
    func viewDidAppear() {}
    func viewWillDisappear() {}
    func viewDidDisappear() {}
    func viewWillDeallocate() {}
    func viewDidDeallocate() {}
    
    func viewWillAnimateAppearance() {}
    func viewDidAnimateAppearance() {}
    func viewWillAnimateDisappearance() {}
    func viewDidAnimateDisappearance() {}
    func viewShouldAppear(_ presented: Bool) {}
}

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
}

// MARK: - ViewLifecycleBehavior Implementation

extension ViewLifecycleBehavior {
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
}

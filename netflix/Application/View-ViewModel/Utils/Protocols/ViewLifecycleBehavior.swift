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
    func viewDidConfigure()
    func viewDidTargetSubviews()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidDeallocate()
    
    func prepareForReuse()
}

// MARK: - Default Implementation

extension ViewLifecycleBehavior {
    func viewDidLoad() {}
    func viewDidLoadBehaviors() {}
    func viewDidDeploySubviews() {}
    func viewDidConfigure() {}
    func viewDidTargetSubviews() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    func viewDidDeallocate() {}
    
    func prepareForReuse() {}
}

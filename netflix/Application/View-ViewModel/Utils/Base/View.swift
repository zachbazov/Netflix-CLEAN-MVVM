//
//  View.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ViewModeling Type

protocol ViewModeling {
    associatedtype T: ViewModel
    var viewModel: T! { get set }
}

// MARK: - View<T> Type

class View<T>: UIView where T: ViewModel {
    var viewModel: T!
    
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
    
    func viewWillBindObservers() {}
    func viewDidBindObservers() {}
    func viewWillUnbindObservers() {}
    func viewDidUnbindObservers() {}
    
    func viewWillConstraint() {}
    func viewDidConstraint() {}
    
    func viewWillAnimateAppearance() {}
    func viewWillAnimateDisappearance() {}
    func viewShouldAppear(_ presented: Bool) {
        guard presented else { return self.viewWillAnimateDisappearance() }
        
        self.viewWillAnimateAppearance()
    }
    
    func prepareForReuse() {}
}

// MARK: - ViewModeling Implementation

extension View: ViewModeling {}

// MARK: - ViewLifecycleBehavior Implementation

extension View: ViewLifecycleBehavior {}

// MARK: - ViewObserving Implementation

extension View: ViewObserving {}

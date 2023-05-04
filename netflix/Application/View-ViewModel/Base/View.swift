//
//  View.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ViewObserving Type

protocol ViewObserving {
    func viewDidBindObservers()
    func viewDidUnbindObservers()
}

// MARK: - ViewModeling Type

protocol ViewModeling {
    associatedtype T: ViewModel
    var viewModel: T! { get set }
}

// MARK: - View<T> Type

class View<T>: UIView where T: ViewModel {
    var viewModel: T!
    
    func dataDidDownload() {}
    
    func viewDidLoad() {}
    func viewDidDeploySubviews() {}
    func viewDidConfigure() {}
    func viewDidTargetSubviews() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    
    func viewDidBindObservers() {}
    func viewDidUnbindObservers() {}
    
    func viewWillAnimateAppearance() {}
    func viewWillAnimateDisappearance() {}
    func viewShouldAppear(_ presented: Bool) {
        guard presented else { return self.viewWillAnimateDisappearance() }
        
        self.viewWillAnimateAppearance()
    }
    
    func viewWillDeallocate() {}
    func viewDidDeallocate() {}
    
    func prepareForReuse() {}
}

// MARK: - ViewModeling Implementation

extension View: ViewModeling {}

// MARK: - ViewLifecycleBehavior Implementation

extension View: ViewLifecycleBehavior {}

// MARK: - ViewObserving Implementation

extension View: ViewObserving {}

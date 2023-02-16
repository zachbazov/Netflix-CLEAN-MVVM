//
//  View.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

private protocol ViewObserving {
    func viewObserversDidBind()
    func viewObserversDidUnbind()
}

protocol Viewable {
    associatedtype T: ViewModel
    var viewModel: T! { get set }
}

class View<T>: UIView, Viewable where T: ViewModel {
    var viewModel: T!
    
    func viewDidDeploySubviews() {}
    func viewDidConfigure<T: ViewModel>(with viewModel: T) {}
    
    func viewObserversDidBind() {}
    func viewObserversDidUnbind() {}
}

extension View: ViewObserving {}

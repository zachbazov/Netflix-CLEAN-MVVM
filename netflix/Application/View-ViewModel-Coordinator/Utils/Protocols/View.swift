//
//  View.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - View Type

protocol View: UIView,
               ViewLifecycleBehavior,
               ViewObservable,
               ViewAnimatable {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! { get set }
}

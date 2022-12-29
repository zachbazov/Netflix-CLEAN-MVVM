//
//  View.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import Foundation

// MARK: - View Protocol

protocol View {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! { get set }
}

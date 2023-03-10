//
//  AccountViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    
}

private protocol ViewModelOutput {
    
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - AccountViewModel Type

final class AccountViewModel {
    var coordinator: AccountViewCoordinator?
}

// MARK: - ViewModel Implementation

extension AccountViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension AccountViewModel: ViewModelProtocol {}

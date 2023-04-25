//
//  BrowseOverlayViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var isPresented: Observable<Bool> { get }
    var section: Observable<Section> { get }
}

// MARK: - BrowseOverlayViewModel Type

struct BrowseOverlayViewModel {
    let coordinator: HomeViewCoordinator
    
    let isPresented: Observable<Bool> = Observable(false)
    let section: Observable<Section> = Observable(.vacantValue)
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension BrowseOverlayViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension BrowseOverlayViewModel: ViewModelProtocol {}

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
    
    func isPresentedWillChange(_ presented: Bool)
    func sectionWillChange(_ section: Section)
    func sectionDidChange(_ section: Section)
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

extension BrowseOverlayViewModel: ViewModelProtocol {
    func isPresentedWillChange(_ presented: Bool) {
        isPresented.value = presented
    }
    
    func sectionWillChange(_ section: Section) {
        self.section.value = section
    }
    
    func sectionDidChange(_ section: Section) {
        guard let controller = coordinator.viewController,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        browseOverlay.dataSource?.section = section
    }
}

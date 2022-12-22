//
//  DisplayTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 21/11/2022.
//

import Foundation

struct DisplayTableViewCellViewModel {
    weak var coordinator: HomeViewCoordinator?
    let presentedMedia: Observable<Media?>
    let myList: MyList
    let sectionAt: (HomeTableViewDataSource.Index) -> Section
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.presentedMedia = self.coordinator!.viewController!.viewModel.presentedDisplayMedia
        self.myList = viewModel.myList
        self.sectionAt = viewModel.section(at:)
    }
}

extension DisplayTableViewCellViewModel {
    func presentedDisplayMediaDidChange() {
        guard let homeViewModel = coordinator!.viewController!.viewModel,
              let homeDataSourceState = homeViewModel.dataSourceState.value as HomeTableViewDataSource.State? else {
            return
        }
        presentedMedia.value = generateMedia(for: homeDataSourceState)
    }
    
    private func generateMedia(for state: HomeTableViewDataSource.State) -> Media {
        let homeViewModel = coordinator!.viewController!.viewModel!
        let media = homeViewModel.media
        
        guard homeViewModel.displayMediaCache[state] == nil else {
            return homeViewModel.displayMediaCache[state]!
        }
        
        if case .all = state {
            homeViewModel.displayMediaCache[state] = media.randomElement()
        } else if case .series = state {
            homeViewModel.displayMediaCache[state] = media.filter { $0.type == .series }.randomElement()!
        } else if case .films = state {
            homeViewModel.displayMediaCache[state] = media.filter { $0.type == .film }.randomElement()!
        }
        
        return homeViewModel.displayMediaCache[state]!
    }
}

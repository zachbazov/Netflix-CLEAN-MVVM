//
//  DisplayTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 21/11/2022.
//

import Foundation

// MARK: - DisplayTableViewCellViewModel Type

struct DisplayTableViewCellViewModel {
    
    // MARK: Properties
    
    weak var coordinator: HomeViewCoordinator?
    let presentedMedia: Observable<Media?>
    let myList: MyList
    let sectionAt: (HomeTableViewDataSource.Index) -> Section
    
    // MARK: Initializer
    
    /// Create a display table view cell view model.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.presentedMedia = self.coordinator!.viewController!.viewModel.displayMedia
        self.myList = viewModel.myList
        self.sectionAt = viewModel.section(at:)
        self.viewDidLoad()
    }
}

// MARK: - Methods

extension DisplayTableViewCellViewModel {
    private func viewDidLoad() {
        generateMedia()
        setMedia()
    }
    /// Generate a media object for each (home) data source state and fixed it.
    private func generateMedia() {
        let homeViewModel = coordinator!.viewController!.viewModel!
        /// Data of all media.
        let media = homeViewModel.media
        
        HomeTableViewDataSource.State.allCases.forEach {
            guard homeViewModel.displayMediaCache[$0] == nil else { return }
            if case .all = $0 {
                homeViewModel.displayMediaCache[$0] = media.randomElement()
            } else if case .tvShows = $0 {
                homeViewModel.displayMediaCache[$0] = media.filter { $0.type == "series" }.randomElement()!
            } else if case .movies = $0 {
                homeViewModel.displayMediaCache[$0] = media.filter { $0.type == "film" }.randomElement()!
            }
        }
    }
    /// Set a display view media according to the data source state.
    func setMedia() {
        let homeViewModel = coordinator!.viewController!.viewModel!
        
        if case .all = homeViewModel.dataSourceState.value {
            presentedMedia.value = homeViewModel.displayMediaCache[.all]
        } else if case .tvShows = homeViewModel.dataSourceState.value {
            presentedMedia.value = homeViewModel.displayMediaCache[.tvShows]
        } else {
            presentedMedia.value = homeViewModel.displayMediaCache[.movies]
        }
    }
}

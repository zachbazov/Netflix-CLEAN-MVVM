//
//  ShowcaseTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 21/11/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var presentedMedia: Observable<Media?> { get }
    var myList: MyList { get }
    var sectionAt: (HomeTableViewDataSource.Index) -> Section { get }
    
    func viewMediaDidGenerate()
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - ShowcaseTableViewCellViewModel Type

struct ShowcaseTableViewCellViewModel {
    weak var coordinator: HomeViewCoordinator?
    
    let presentedMedia: Observable<Media?>
    let myList: MyList
    let sectionAt: (HomeTableViewDataSource.Index) -> Section
    /// Create a display table view cell view model.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.presentedMedia = self.coordinator!.viewController!.viewModel.showcase
        self.myList = viewModel.myList
        self.sectionAt = viewModel.section(at:)
        self.viewDidLoad()
    }
}

// MARK: - ViewModelProtocol Implementation

extension ShowcaseTableViewCellViewModel: ViewModelProtocol {
    /// Generate a media object for each (home) data source state and fixed it.
    fileprivate func viewMediaDidGenerate() {
        let homeViewModel = coordinator!.viewController!.viewModel!
        let media = homeViewModel.media
        // Pull and store a random media element.
        HomeTableViewDataSource.State.allCases.forEach {
            guard homeViewModel.showcases[$0] == nil else { return }
            switch $0 {
            case .all:
                homeViewModel.showcases[$0] = media.randomElement()
            case .tvShows:
                homeViewModel.showcases[$0] = media.filter { $0.type == "series" }.randomElement()!
            case .movies:
                homeViewModel.showcases[$0] = media.filter { $0.type == "film" }.randomElement()!
            }
        }
        // Set a display view media according to the data source state.
        switch homeViewModel.dataSourceState.value {
        case .all:
            presentedMedia.value = homeViewModel.showcases[.all]
        case .tvShows:
            presentedMedia.value = homeViewModel.showcases[.tvShows]
        case .movies:
            presentedMedia.value = homeViewModel.showcases[.movies]
        }
    }
}

// MARK: - ViewModel Implementation

extension ShowcaseTableViewCellViewModel: ViewModel {
    func viewDidLoad() {
        viewMediaDidGenerate()
    }
}

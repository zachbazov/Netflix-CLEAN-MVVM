//
//  DetailViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import Foundation

// MARK: - DetailViewModel Type

final class DetailViewModel {
    
    // MARK: Properties
    
    var coordinator: DetailViewCoordinator?
    private let useCase: DetailUseCase
    let section: Section
    var media: Media
    private let orientation = DeviceOrientation.shared
    var isRotated: Bool? { didSet { shouldScreenRotate() } }
    private(set) var homeDataSourceState: HomeTableViewDataSource.State!
    private(set) var navigationViewState: Observable<DetailNavigationView.State>! = Observable(.episodes)
    private(set) var season: Observable<Season?>! = Observable(nil)
    private(set) var myList: MyList!
    private(set) var myListSection: Section!
    private var task: Cancellable? { willSet { task?.cancel() } }
    
    // MARK: Initializer
    
    /// Create a detail view model object.
    /// - Parameters:
    ///   - section: The section that corresponds to the media object.
    ///   - media: Corresponding media object.
    ///   - viewModel: Coordinating view model.
    init(section: Section, media: Media, with viewModel: HomeViewModel) {
        let dataTransferService = Application.current.dataTransferService
        let repository = SeasonRepository(dataTransferService: dataTransferService)
        let useCase = DetailUseCase(seasonsRepository: repository)
        self.useCase = useCase
        self.section = section
        self.media = media
        self.homeDataSourceState = viewModel.dataSourceState.value
        self.myList = viewModel.myList
        self.myListSection = viewModel.myList.viewModel.section
    }
    
    // MARK: Deinitializer
    
    deinit {
        isRotated = nil
        myList = nil
        myListSection = nil
        season.value = nil
        navigationViewState = nil
        homeDataSourceState = nil
        task = nil
    }
}

// MARK: - ViewModel Implementation

extension DetailViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - Methods

extension DetailViewModel {
    private func shouldScreenRotate() {
        orientation.setLock(orientation: .all)
        
        if isRotated ?? false {
            asynchrony(dispatchingDelayInSeconds: 1) { [weak orientation] in
                orientation?.set(orientation: .landscapeLeft)
            }
        }
    }
    
    func resetOrientation() {
        orientation.setLock(orientation: .portrait)
    }
}

// MARK: - DetailUseCase Implementation

extension DetailViewModel {
    func getSeason(with request: SeasonRequestDTO.GET, completion: @escaping () -> Void) {
        task = useCase.execute(for: SeasonResponse.self,
                               with: request) { [weak self] result in
            if case let .success(responseDTO) = result {
                var season = responseDTO.data
                season.episodes = season.episodes.sorted { $0.episode < $1.episode }
                self?.season.value = season
                completion()
            }
            if case let .failure(error) = result { print(error) }
        }
    }
}

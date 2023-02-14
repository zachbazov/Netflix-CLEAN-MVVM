//
//  DetailViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import Foundation

// MARK: - DetailViewModel Type

final class DetailViewModel {
    var coordinator: DetailViewCoordinator?
    
    private lazy var seasonRepository: SeasonRepository = createSeasonRepository()
    private lazy var seasonRouter = Router<SeasonRepository>(repository: seasonRepository)
    
    let section: Section
    var media: Media
    private let orientation = DeviceOrientation.shared
    var isRotated: Bool? { didSet { shouldScreenRotate() } }
    private(set) var homeDataSourceState: HomeTableViewDataSource.State!
    private(set) var navigationViewState: Observable<DetailNavigationView.State>! = Observable(.episodes)
    private(set) var season: Observable<Season?>! = Observable(nil)
    private(set) var myList: MyList!
    private(set) var myListSection: Section!
    /// Create a detail view model object.
    /// - Parameters:
    ///   - section: The section that corresponds to the media object.
    ///   - media: Corresponding media object.
    ///   - viewModel: Coordinating view model.
    init(section: Section, media: Media, with viewModel: HomeViewModel) {
        self.section = section
        self.media = media
        self.homeDataSourceState = viewModel.dataSourceState.value
        self.myList = viewModel.myList
        self.myListSection = viewModel.myList.viewModel.section
    }
    
    deinit {
        isRotated = nil
        myList = nil
        myListSection = nil
        season.value = nil
        navigationViewState = nil
        homeDataSourceState = nil
    }
    
    private func createSeasonRepository() -> SeasonRepository {
        let dataTransferService = Application.app.services.dataTransfer
        return SeasonRepository(dataTransferService: dataTransferService)
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
            mainQueueDispatch(delayInSeconds: 1) { [weak orientation] in
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
    func getSeason(with request: SeasonHTTPDTO.Request, completion: @escaping () -> Void) {
        seasonRepository.task = seasonRouter.request(for: SeasonHTTPDTO.Response.self,
                                                     request: request) { [weak self] result in
            if case let .success(responseDTO) = result {
                var season = responseDTO.data.first!
                season.episodes = season.episodes.sorted { $0.episode < $1.episode }
                self?.season.value = season.toDomain()
                completion()
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        }
    }
}

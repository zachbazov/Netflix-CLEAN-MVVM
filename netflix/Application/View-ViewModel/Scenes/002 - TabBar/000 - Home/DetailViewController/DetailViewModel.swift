//
//  DetailViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var useCase: SeasonUseCase { get }
    var orientation: DeviceOrientation { get }
    
    var homeDataSourceState: HomeTableViewDataSource.State! { get }
    
    var section: Section { get }
    var media: Media { get }
    var isRotated: Bool? { get }
    
    var navigationViewState: Observable<DetailNavigationView.State>! { get }
    var season: Observable<Season?>! { get }
    var myList: MyList! { get }
    var myListSection: Section! { get }
    
    func shouldScreenRotate()
    func resetOrientation()
    
    func getSeason(with request: SeasonHTTPDTO.Request, completion: @escaping () -> Void)
}

// MARK: - DetailViewModel Type

final class DetailViewModel {
    var coordinator: DetailViewCoordinator?
    
    fileprivate let useCase = SeasonUseCase()
    let orientation = DeviceOrientation.shared
    
    fileprivate(set) var homeDataSourceState: HomeTableViewDataSource.State!
    
    let section: Section
    var media: Media
    var isRotated: Bool? { didSet { shouldScreenRotate() } }
    
    fileprivate(set) var navigationViewState: Observable<DetailNavigationView.State>! = Observable(.episodes)
    fileprivate(set) var season: Observable<Season?>! = Observable(nil)
    fileprivate(set) var myList: MyList!
    fileprivate(set) var myListSection: Section!
    
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
}

// MARK: - ViewModel Implementation

extension DetailViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailViewModel: ViewModelProtocol {
    fileprivate func shouldScreenRotate() {
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
    
    func getSeason(with request: SeasonHTTPDTO.Request, completion: @escaping () -> Void) {
        useCase.repository.task = useCase.request(endpoint: .getSeason,
                                                  for: SeasonHTTPDTO.Response.self,
                                                  request: request,
                                                  cached: nil,
                                                  completion: { [weak self] result in
            if case let .success(responseDTO) = result {
                guard var season = responseDTO.data.first else { return }
                season.episodes = season.episodes.sorted { $0.episode < $1.episode }
                self?.season.value = season.toDomain()
                
                completion()
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        })
    }
}

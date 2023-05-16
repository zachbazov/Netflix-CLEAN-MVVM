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
    var myList: MyList { get }
    
    var section: Section? { get }
    var media: Media? { get }
    var isRotated: Bool { get }
    
    var navigationViewState: Observable<DetailNavigationView.State> { get }
    var season: Observable<Season> { get }
    var collectionMedia: Observable<[Mediable]> { get }
    
    func shouldScreenRotate()
}

// MARK: - DetailViewModel Type

final class DetailViewModel {
    var coordinator: DetailViewCoordinator?
    
    fileprivate let useCase = SeasonUseCase()
    let orientation = DeviceOrientation.shared
    let myList = MyList.shared
    
    var section: Section?
    var media: Media?
    var isRotated: Bool = false
    
    let navigationViewState: Observable<DetailNavigationView.State> = Observable(.episodes)
    let season: Observable<Season> = Observable(.vacantValue)
    let collectionMedia: Observable<[Mediable]> = Observable([])
    
    deinit {
        media = nil
        section = nil
        coordinator = nil
    }
}

// MARK: - ViewModel Implementation

extension DetailViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailViewModel: ViewModelProtocol {
    func shouldScreenRotate() {
        mainQueueDispatch(delayInSeconds: 1) { [weak self] in
            guard let self = self else { return }
            
            self.orientation.set(orientation: self.isRotated ? .landscapeLeft : .portrait)
        }
    }
}

// MARK: - DataProviderProtocol Type

private protocol DataProviderProtocol {
    func seasonDidLoad(request: SeasonHTTPDTO.Request, _ completion: @escaping () -> Void)
    
    func seasonDidLoad() async
}

// MARK: - DataProviderProtocol Implementation

extension DetailViewModel: DataProviderProtocol {
    func seasonDidLoad(request: SeasonHTTPDTO.Request, _ completion: @escaping () -> Void) {
        useCase.repository.task = useCase.request(
            endpoint: .getSeason,
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
    
    func seasonDidLoad() async {}
}

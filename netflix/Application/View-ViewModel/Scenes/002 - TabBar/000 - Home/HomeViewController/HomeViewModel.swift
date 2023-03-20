//
//  HomeViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func section(at index: HomeTableViewDataSource.Index) -> Section
    func filter(sections: [Section])
    func filter(at index: HomeTableViewDataSource.Index) -> [Media]
}

private protocol ViewModelOutput {
    var sectionUseCase: SectionUseCase { get }
    var mediaUseCase: MediaUseCase { get }
    
    var orientation: DeviceOrientation { get }
    
    var sections: [Section] { get }
    var media: [Media] { get }
    var topSearches: [Media] { get }
    
    var dataSourceState: Observable<HomeTableViewDataSource.State> { get }
    var showcase: Observable<Media?> { get }
    var showcases: [HomeTableViewDataSource.State: Media] { get }
    
    var myList: MyList { get }
    
    var isSectionsEmpty: Bool { get }
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - HomeViewModel Type

final class HomeViewModel {
    var coordinator: HomeViewCoordinator?
    
    fileprivate lazy var sectionUseCase = SectionUseCase()
    fileprivate lazy var mediaUseCase = MediaUseCase()
    
    fileprivate let orientation = DeviceOrientation.shared
    
    fileprivate(set) lazy var sections = [Section]()
    fileprivate(set) lazy var media = [Media]()
    fileprivate(set) lazy var topSearches = [Media]()
    
    let dataSourceState: Observable<HomeTableViewDataSource.State> = Observable(.all)
    let showcase: Observable<Media?> = Observable(.none)
    lazy var showcases = [HomeTableViewDataSource.State: Media]()
    
    fileprivate(set) lazy var myList = MyList(with: self)
    
    var isSectionsEmpty: Bool { return sections.isEmpty }
    
    deinit {
        myList.viewDidUnbindObservers()
        coordinator = nil
    }
}

// MARK: - ViewModel Implementation

extension HomeViewModel: ViewModel {
    func viewDidLoad() {
        ActivityIndicatorView.viewDidShow()
        
        loadData()
    }
    
    func dataDidDownload() {
        ActivityIndicatorView.viewDidHide()
        
        mainQueueDispatch { [weak self] in
            let navigationViewModel = self?.coordinator?.viewController?.navigationView.viewModel
            navigationViewModel?.navigationViewDidAppear()
        }
        
        notifyObservers()
    }
}

// MARK: - Coordinable Implementation

extension HomeViewModel: Coordinable {}

// MARK: - ViewModelProtocol Implementation

extension HomeViewModel: ViewModelProtocol {
    /// Given a specific index, returns a section object.
    /// - Parameter index: A representation of the section's index.
    /// - Returns: A section.
    func section(at index: HomeTableViewDataSource.Index) -> Section {
        return sections[index.rawValue]
    }
    /// Filter all the sections based on the state of the table view data source.
    /// - Parameter sections: The sections to be filtered.
    func filter(sections: [Section]) {
        guard !isSectionsEmpty else { return }
        
        HomeTableViewDataSource.Index.allCases.forEach {
            sections[$0.rawValue].media = filter(at: $0)
        }
    }
    /// Filter a section based on an index of the table view data source.
    /// - Parameter index: Representation of the section's index.
    /// - Returns: Filtered media array.
    fileprivate func filter(at index: HomeTableViewDataSource.Index) -> [Media] {
        switch index {
        case .rated:
            switch dataSourceState.value {
            case .all:
                return media
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            case .tvShows:
                return media
                    .filter { $0.type == "series" }
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            case .movies:
                return media
                    .filter { $0.type == "film" }
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            }
        case .resumable:
            switch dataSourceState.value {
            case .all:
                return media.shuffled()
            case .tvShows:
                return media.shuffled().filter { $0.type == "series" }
            case .movies:
                return media.shuffled().filter { $0.type == "film" }
            }
        case .myList:
            let media = myList.viewModel.list.value
            switch dataSourceState.value {
            case .all:
                return media.shuffled()
            case .tvShows:
                return media.shuffled().filter { $0.type == "series" }
            case .movies:
                return media.shuffled().filter { $0.type == "film" }
            }
        case .blockbuster:
            let value = Float(7.5)
            switch dataSourceState.value {
            case .all:
                return media.filter { $0.rating > value }
            case .tvShows:
                return media.filter { $0.type == "series" }.filter { $0.rating > value }
            case .movies:
                return media.filter { $0.type == "film" }.filter { $0.rating > value }
            }
        default:
            switch dataSourceState.value {
            case .all:
                return media
                    .shuffled()
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            case .tvShows:
                return media
                    .shuffled()
                    .filter { $0.type == "series" }
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            case .movies:
                return media
                    .shuffled()
                    .filter { $0.type == "film" }
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            }
        }
    }
}

// MARK: - Private UI Implementation

extension HomeViewModel {
    private func notifyObservers() {
        dataSourceState.value = .all
    }
}

// MARK: - DataProviderProtocol Type

private protocol DataProviderInput {
    func sectionsDidLoad(_ completion: @escaping () -> Void)
    func mediaDidLoad(_ completion: @escaping () -> Void)
    func topSearchesDidLoad(_ completion: @escaping () -> Void)
    
    func sectionsDidLoad() async
    func mediaDidLoad() async
    func topSearchesDidLoad() async
}

private protocol DataProviderOutput {
    func loadData()
    func awaitLoading()
    func dispatchGroupLoading()
}

private typealias DataProviderProtocol = DataProviderInput & DataProviderOutput

// MARK: - DataProviderProtocol Implementation

extension HomeViewModel: DataProviderProtocol {
    func loadData() {
        if #available(iOS 13.0, *) {
            return awaitLoading()
        }
        
        dispatchGroupLoading()
    }
    
    fileprivate func dispatchGroupLoading() {
        let group = DispatchGroup()
        
        group.enter()
        sectionsDidLoad { group.leave() }
        group.enter()
        mediaDidLoad { group.leave() }
        group.enter()
        topSearchesDidLoad { group.leave() }
        
        group.notify(queue: .main) { [weak self] in self?.dataDidDownload() }
    }
    
    fileprivate func awaitLoading() {
        Task {
            await sectionsDidLoad()
            await mediaDidLoad()
            await topSearchesDidLoad()
            
            dataDidDownload()
        }
    }
    
    fileprivate func sectionsDidLoad(_ completion: @escaping () -> Void) {
        sectionUseCase.repository.task = sectionUseCase.request(
            endpoint: .getSections,
            for: SectionHTTPDTO.Response.self,
            request: SectionHTTPDTO.Request.self,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.sections = response.data.toDomain()
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                    
                    let authService = Application.app.services.authentication
                    authService.signOut()
                }
            })
    }
    
    fileprivate func mediaDidLoad(_ completion: @escaping () -> Void) {
        mediaUseCase.repository.task = mediaUseCase.request(
            endpoint: .getAllMedia,
            for: MediaHTTPDTO.Response.self,
            request: MediaHTTPDTO.Request.self,
            cached: { [weak self] responseDTO in
                guard let self = self, let response = responseDTO else { return }
                
                self.media = response.data.toDomain()
                
                completion()
            }, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.media = response.data.toDomain()
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func topSearchesDidLoad(_ completion: @escaping () -> Void) {
        mediaUseCase.repository.task = mediaUseCase.request(
            endpoint: .getTopSearches,
            for: SearchHTTPDTO.Response.self,
            request: SearchHTTPDTO.Request.self,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.topSearches = response.data.toDomain()
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func sectionsDidLoad() async {
        let response = await sectionUseCase.request(endpoint: .getSections, for: SectionHTTPDTO.Response.self)
        guard let sections = response?.data.toDomain() else { return }
        self.sections = sections
    }
    
    fileprivate func mediaDidLoad() async {
        let response = await mediaUseCase.request(endpoint: .getAllMedia, for: MediaHTTPDTO.Response.self)
        guard let media = response?.data.toDomain() else { return }
        self.media = media
    }
    
    fileprivate func topSearchesDidLoad() async {
        let response = await mediaUseCase.request(endpoint: .getTopSearches, for: SearchHTTPDTO.Response.self)
        guard let media = response?.data.toDomain() else { return }
        self.topSearches = media
    }
}
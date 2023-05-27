//
//  HomeViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var sectionUseCase: SectionUseCase { get }
    var mediaUseCase: MediaUseCase { get }
    
    var orientation: DeviceOrientation { get }
    var myList: MyList { get }
    
    var sections: [Section] { get }
    var media: [Media] { get }
    var topSearches: [Media] { get }
    
    var dataSourceState: Observable<MediaTableViewDataSource.State> { get }
    var showcases: [MediaTableViewDataSource.State: Media] { get }
    
    var isSectionsEmpty: Bool { get }
    
    func changeDataSourceStateIfNeeded(_ state: MediaTableViewDataSource.State)
    func dataSourceStateWillChange(_ state: MediaTableViewDataSource.State)
    
    func section(at index: MediaTableViewDataSource.Index) -> Section
    func filter(at index: MediaTableViewDataSource.Index) -> [Media]
    func filter(at state: MediaTableViewDataSource.State) -> Media?
    func sectionsWillFilter()
    func showcasesWillFilter()
}

// MARK: - HomeViewModel Type

final class HomeViewModel {
    var coordinator: HomeViewCoordinator?
    
    fileprivate lazy var sectionUseCase: SectionUseCase = createSectionUseCase()
    fileprivate lazy var mediaUseCase: MediaUseCase = createMediaUseCase()
    
    fileprivate let orientation = DeviceOrientation.shared
    fileprivate let myList = MyList.shared
    
    private(set) lazy var sections = [Section]()
    private(set) lazy var media = [Media]()
    private(set) lazy var topSearches = [Media]()
    
    let dataSourceState: Observable<MediaTableViewDataSource.State> = Observable(.all)
    private(set) lazy var showcases = [MediaTableViewDataSource.State: Media]()
    
    var isSectionsEmpty: Bool { return sections.isEmpty }
    
    deinit {
        print("deinit \(Self.self)")
        
        coordinator = nil
    }
}

// MARK: - ViewModel Implementation

extension HomeViewModel: ViewModel {
    func viewDidLoad() {
        dataWillLoad()
    }
    
    func dataWillLoad() {
        ActivityIndicatorView.present()
        
        if #available(iOS 13.0, *) {
            return loadUsingAsyncAwait()
        }
        
        loadUsingDispatchGroup()
    }
    
    func dataDidLoad() {
        ActivityIndicatorView.remove()
        
        showcasesWillFilter()
        
        dataSourceStateWillChange(.all)
    }
}

// MARK: - CoordinatorAssignable Implementation

extension HomeViewModel: CoordinatorAssignable {}

// MARK: - ViewModelProtocol Implementation

extension HomeViewModel: ViewModelProtocol {
    func dataSourceStateWillChange(_ state: MediaTableViewDataSource.State) {
        dataSourceState.value = state
    }
    
    func changeDataSourceStateIfNeeded(_ state: MediaTableViewDataSource.State) {
        guard dataSourceState.value != state else { return }
        
        dataSourceState.value = state
    }
    
    /// Given a specific index, returns a section object.
    /// - Parameter index: A representation of the section's index.
    /// - Returns: A section.
    func section(at index: MediaTableViewDataSource.Index) -> Section {
        guard !isSectionsEmpty else { return .vacantValue }
        
        return sections[index.rawValue]
    }
    
    /// Filter all the sections based on the state of the table view data source.
    /// - Parameter sections: The sections to be filtered.
    func sectionsWillFilter() {
        guard !isSectionsEmpty else { return }
        
        MediaTableViewDataSource.Index.allCases.forEach {
            sections[$0.rawValue].media = filter(at: $0)
        }
    }
    
    fileprivate func showcasesWillFilter() {
        MediaTableViewDataSource.State.allCases.forEach {
            showcases[$0] = filter(at: $0)
        }
    }
    
    fileprivate func filter(at state: MediaTableViewDataSource.State) -> Media? {
        guard showcases[state] == nil else { return nil }
        
        switch state {
        case .all:
            return media.randomElement()
        case .tvShows:
            return media.filter { $0.type == "series" }.randomElement()
        case .movies:
            return media.filter { $0.type == "film" }.randomElement()
        }
    }
    
    /// Filter a section based on an index of the table view data source.
    /// - Parameter index: Representation of the section's index.
    /// - Returns: Filtered media array.
    fileprivate func filter(at index: MediaTableViewDataSource.Index) -> [Media] {
        switch index {
        case .newRelease:
            switch dataSourceState.value {
            case .all:
                return media.shuffled().filter { $0.isNewRelease }
            case .tvShows:
                return media.filter { $0.type == "series" && $0.isNewRelease }
            case .movies:
                return media.filter { $0.type == "film" && $0.isNewRelease }
            }
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
            let media = myList.viewModel.list
            
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

// MARK: - DataProviderProtocol Type

private protocol DataProviderProtocol {
    func sectionsDidLoad(_ completion: @escaping () -> Void)
    func mediaDidLoad(_ completion: @escaping () -> Void)
    func topSearchesDidLoad(_ completion: @escaping () -> Void)
    
    func sectionsDidLoad() async
    func mediaDidLoad() async
    func topSearchesDidLoad() async
    
    func loadUsingAsyncAwait()
    func loadUsingDispatchGroup()
}

// MARK: - DataProviderProtocol Implementation

extension HomeViewModel: DataProviderProtocol {
    fileprivate func loadUsingDispatchGroup() {
        let group = DispatchGroup()
        
        group.enter()
        sectionsDidLoad { group.leave() }
        group.enter()
        mediaDidLoad { group.leave() }
        group.enter()
        topSearchesDidLoad { group.leave() }
        
        group.notify(queue: .main) { [weak self] in self?.dataDidLoad() }
    }
    
    fileprivate func loadUsingAsyncAwait() {
        Task {
            await sectionsDidLoad()
            await mediaDidLoad()
            await topSearchesDidLoad()
            
            dataDidLoad()
        }
    }
    
    fileprivate func sectionsDidLoad(_ completion: @escaping () -> Void) {
        sectionUseCase.repository.task = sectionUseCase.request(
            endpoint: .getSections,
            for: SectionHTTPDTO.Response.self,
            request: SectionHTTPDTO.Request.self,
            cached: { [weak self] response in
                guard let self = self, let response = response else { return }
                
                self.sections = response.data.toDomain()
                
                completion()
            },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.sections = response.data.toDomain()
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                    
                    let authService = Application.app.services.authentication
                    authService.signOut(nil)
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

// MARK: - Private Implementation

extension HomeViewModel {
    private func createSectionUseCase() -> SectionUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = SectionRepository(dataTransferService: dataTransferService)
        return SectionUseCase(repository: repository)
    }
    
    private func createMediaUseCase() -> MediaUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = MediaRepository(dataTransferService: dataTransferService)
        return MediaUseCase(repository: repository)
    }
}

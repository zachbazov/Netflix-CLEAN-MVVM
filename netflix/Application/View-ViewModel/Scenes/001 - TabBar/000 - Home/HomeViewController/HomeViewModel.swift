//
//  HomeViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - ViewModelNetworking Type

private protocol ViewModelNetworking {
    func loadSections()
    func loadMedia()
}

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
    
    var dataSourceState: Observable<HomeTableViewDataSource.State> { get }
    
    var sections: [Section] { get }
    var media: [Media] { get }
    var isSectionsEmpty: Bool { get }
    
    var showcase: Observable<Media?> { get }
    var showcases: [HomeTableViewDataSource.State: Media] { get }
    
    var myList: MyList { get }
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - HomeViewModel Type

final class HomeViewModel {
    var coordinator: HomeViewCoordinator?
    
    lazy var sectionUseCase = SectionUseCase()
    lazy var mediaUseCase = MediaUseCase()
    
    let orientation = DeviceOrientation.shared
    
    let dataSourceState: Observable<HomeTableViewDataSource.State> = Observable(.all)
    
    private(set) var sections = [Section]()
    private(set) var media = [Media]()
    var isSectionsEmpty: Bool { return sections.isEmpty }
    
    let showcase: Observable<Media?> = Observable(.none)
    var showcases: [HomeTableViewDataSource.State: Media] = [:]
    
    lazy var myList = MyList(with: self)
    
    deinit {
        myList.removeObservers()
        coordinator = nil
    }
}

// MARK: - Private UI Implementation

extension HomeViewModel {
    func viewDidLoad() {
        loadSections()
    }
    
    private func dataDidDownload() {
        let navigationViewModel = coordinator?.viewController?.navigationView.viewModel
        navigationViewModel?.navigationViewDidAppear()
        
        updateDataSource()
    }
    
    private func updateDataSource() {
        dataSourceState.value = .all
    }
}

// MARK: - ViewModel Implementation

extension HomeViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - ViewModelNetworking Implementation

extension HomeViewModel: ViewModelNetworking {
    fileprivate func loadSections() {
        sectionUseCase.repository.task = sectionUseCase.request(
            for: SectionHTTPDTO.Response.self,
            request: Any.self,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(response) = result {
                    /// Allocate sections with the response data.
                    self.sections = response.data.toDomain()
                    /// Execute media fetching operation.
                    self.loadMedia()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func loadMedia() {
        mediaUseCase.repository.task = mediaUseCase.request(
            for: MediaHTTPDTO.Response.self,
            request: Any.self,
            cached: { [weak self] responseDTO in
                guard let self = self, let response = responseDTO else { return }
                mainQueueDispatch {
                    self.media = response.data.toDomain()
                    
                    self.dataDidDownload()
                }
            }, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.media = response.data.toDomain()
                    
                    self.dataDidDownload()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
}

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

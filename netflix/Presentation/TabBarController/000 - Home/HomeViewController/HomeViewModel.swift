//
//  HomeViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - HomeViewModel Type

final class HomeViewModel {
    
    // MARK: Properties
    
    var coordinator: HomeViewCoordinator?
    let useCase: HomeUseCase
    let orientation = DeviceOrientation.shared
    
    let dataSourceState: Observable<HomeTableViewDataSource.State> = Observable(.all)
    // The media object for the `DisplayView` to present.
    let displayMedia: Observable<Media?> = Observable(.none)
    
    private(set) var sections: [Section] = []
    private(set) var media: [Media] = []
    var isEmpty: Bool { sections.isEmpty }
    var myList: MyList!
    var displayMediaCache: [HomeTableViewDataSource.State: Media] = [:]
    
    private var sectionsTask: Cancellable? { willSet { sectionsTask?.cancel() } }
    private var mediaTask: Cancellable? { willSet { mediaTask?.cancel() } }
    
    // MARK: Initializer
    
    /// Default initializer.
    /// Allocate `useCase` property and it's dependencies.
    init() {
        let dataTransferService = Application.current.dataTransferService
        let mediaResponseCache = Application.current.mediaResponseCache
        let sectionRepository = SectionRepository(dataTransferService: dataTransferService)
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService, cache: mediaResponseCache)
        let listRepository = ListRepository(dataTransferService: dataTransferService)
        let useCase = HomeUseCase(sectionsRepository: sectionRepository, mediaRepository: mediaRepository, listRepository: listRepository)
        self.useCase = useCase
        self.viewDidLoad()
    }
    
    // MARK: Deinitializer
    
    deinit {
        myList?.removeObservers()
        myList = nil
        mediaTask = nil
        sectionsTask = nil
        coordinator = nil
    }
}

// MARK: - UI Setup

extension HomeViewModel {
    func dataDidBeganLoading() {
        fetchSections()
    }
    
    private func dataDidEndLoading() {
        let navigationViewModel = coordinator?.viewController?.navigationView.viewModel
        navigationViewModel?.navigationViewDidAppear()
        
        dataSourceState.value = .all
        
        myList = MyList(with: self)
    }
    
    private func viewDidLoad() {
        setupOrientation()
    }
    
    private func setupOrientation() {
        let orientation = DeviceOrientation.shared
        orientation.setLock(orientation: .portrait)
    }
}

// MARK: - ViewModel Implementation

extension HomeViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - HomeUseCase implementation

extension HomeViewModel {
    private func fetchSections() {
        sectionsTask = useCase.execute(
            for: SectionResponse.GET.self,
            request: Any.self,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(response) = result {
                    /// Allocate sections with the response data.
                    self.sections = response.data
                    /// Execute media fetching operation.
                    self.fetchMedia()
                }
            })
    }
    
    private func fetchMedia() {
        mediaTask = useCase.execute(
            for: MediaResponse.GET.Many.self,
            request: MediaRequestDTO.self,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(response) = result {
                    /// Allocate media with the response data.
                    self.media = response.data
                    /// Execute after data loading operations.
                    self.dataDidEndLoading()
                }
            })
    }
}

// MARK: - Methods

extension HomeViewModel {
    /// Given a specific index, returns a section object.
    /// - Parameter index: A representation of the section's index.
    /// - Returns: A section.
    func section(at index: HomeTableViewDataSource.Index) -> Section {
        return sections[index.rawValue]
    }
    /// Filter all the sections based on the state of the table view data source.
    /// - Parameter sections: The sections to be filtered.
    func filter(sections: [Section]) {
        guard !isEmpty else { return }
        
        HomeTableViewDataSource.Index.allCases.forEach {
            sections[$0.rawValue].media = filter(at: $0)
        }
    }
    /// Filter a section based on an index of the table view data source.
    /// - Parameter index: Representation of the section's index.
    /// - Returns: Filtered media array.
    private func filter(at index: HomeTableViewDataSource.Index) -> [Media] {
        /// Filter according to the index of the section.
        if case .rated = index {
            /// Filter according to the state of the data source.
            if case .all = dataSourceState.value {
                return media
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            } else if case .tvShows = dataSourceState.value {
                return media
                    .filter { $0.type == .series }
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            } else {
                return media
                    .filter { $0.type == .film }
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            }
        } else if case .resumable = index {
            if case .all = dataSourceState.value {
                return media.shuffled()
            } else if case .tvShows = dataSourceState.value {
                return media.shuffled().filter { $0.type == .series }
            } else {
                return media.shuffled().filter { $0.type == .film }
            }
        } else if case .myList = index {
            
            let media = myList.viewModel.list.value
            if case .all = dataSourceState.value {
                return media.shuffled()
            } else if case .tvShows = dataSourceState.value {
                return media.shuffled().filter { $0.type == .series }
            } else {
                return media.shuffled().filter { $0.type == .film }
            }
        } else if case .blockbuster = index {
            let value = Float(7.5)
            if case .all = dataSourceState.value {
                return media.filter { $0.rating > value }
            } else if case .tvShows = dataSourceState.value {
                return media.filter { $0.type == .series }.filter { $0.rating > value }
            } else {
                return media.filter { $0.type == .film }.filter { $0.rating > value }
            }
        } else {
            if case .all = dataSourceState.value {
                return media
                    .shuffled()
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            } else if case .tvShows = dataSourceState.value {
                return media
                    .shuffled()
                    .filter { $0.type == .series }
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            } else {
                return media
                    .shuffled()
                    .filter { $0.type == .film }
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            }
        }
    }
}

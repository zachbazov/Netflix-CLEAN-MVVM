//
//  HomeViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

final class HomeViewModel {
    var coordinator: HomeViewCoordinator?
    let useCase: HomeUseCase
    let orientation = DeviceOrientation.shared
    
    var dataSourceState: Observable<HomeTableViewDataSource.State> = Observable(.all)
    var presentedDisplayMedia: Observable<Media?> = Observable(.none)
    
    private(set) var sections: [Section] = []
    private(set) var media: [Media] = []
    var isEmpty: Bool { sections.isEmpty }
    var myList: MyList!
    var displayMediaCache: [HomeTableViewDataSource.State: Media] = [:]
    
    private var sectionsTask: Cancellable? { willSet { sectionsTask?.cancel() } }
    private var mediaTask: Cancellable? { willSet { mediaTask?.cancel() } }
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
    }
    
    deinit {
        myList?.removeObservers()
        myList = nil
        mediaTask = nil
        sectionsTask = nil
        coordinator = nil
    }
}

extension HomeViewModel {
    private func viewDidLoad() {
        setupOrientation()
    }
    
    private func setupOrientation() {
        let orientation = DeviceOrientation.shared
        orientation.setLock(orientation: .portrait)
    }
    
    func dataDidBeganLoading() {
        fetchSections()
    }
    
    private func dataDidEndLoading() {
        /// Invoke navigation bar presentation.
        let navigationViewModel = coordinator?.viewController?.navigationView.viewModel
        navigationViewModel?.actions.navigationViewDidAppear()
        /// Invoke table view presentation.
        let tabBarViewModel = Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel
        dataSourceState.value = tabBarViewModel!.latestHomeDataSourceState
        /// Allocate my list.
        myList = MyList(with: self)
    }
}

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
                    self.sections = response.data
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
                    self.media = response.data
                    self.dataDidEndLoading()
                }
            })
    }
}

extension HomeViewModel {
    func section(at index: HomeTableViewDataSource.Index) -> Section {
        sections[index.rawValue]
    }
    
    func filter(sections: [Section]) {
        guard !isEmpty else { return }
        
        HomeTableViewDataSource.Index.allCases.forEach { index in
            sections[index.rawValue].media = filter(at: index)
        }
    }
    
    private func filter(at index: HomeTableViewDataSource.Index) -> [Media] {
        let media = self.media
        if case .rated = index {
            if case .all = dataSourceState.value {
                return media
                    .sorted { $0.rating > $1.rating }
                    .filter { $0.rating > 7.5 }
                    .slice(10)
            } else if case .series = dataSourceState.value {
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
            } else if case .series = dataSourceState.value {
                return media.shuffled().filter { $0.type == .series }
            } else {
                return media.shuffled().filter { $0.type == .film }
            }
        } else if case .myList = index {
            let media = myList.viewModel.list.value
            if case .all = dataSourceState.value {
                return media.shuffled()
            } else if case .series = dataSourceState.value {
                return media.shuffled().filter { $0.type == .series }
            } else {
                return media.shuffled().filter { $0.type == .film }
            }
        } else if case .blockbuster = index {
            let value = Float(7.5)
            if case .all = dataSourceState.value {
                return media.filter { $0.rating > value }
            } else if case .series = dataSourceState.value {
                return media.filter { $0.type == .series }.filter { $0.rating > value }
            } else {
                return media.filter { $0.type == .film }.filter { $0.rating > value }
            }
        } else {
            if case .all = dataSourceState.value {
                return media
                    .shuffled()
                    .filter { $0.genres.contains(sections[index.rawValue].title) }
            } else if case .series = dataSourceState.value {
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

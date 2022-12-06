//
//  HomeViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - HomeViewModelActions struct

struct HomeViewModelActions {
    let navigationViewDidAppear: () -> Void
    let presentMediaDetails: (Section, Media) -> Void
}

//// MARK: - ViewModelInput protocol
//
//private protocol ViewModelInput {
//    func viewWillLoad()
//    func viewDidLoad()
//    func fetchSections()
//    func fetchMedia()
//    func filter(sections: [Section])
//    func section(at index: HomeTableViewDataSource.Index) -> Section
//    func generateMedia(for state: HomeTableViewDataSource.State) -> Media
//    func presentedDisplayMediaDidChange()
//}
//
//// MARK: - ViewModelOutput protocol
//
//private protocol ViewModelOutput {
//    var sections: [Section] { get }
//    var media: [Media] { get }
//    var tableViewState: Observable<HomeTableViewDataSource.State> { get }
//    var presentedDisplayMedia: Observable<Media?> { get }
//    var isEmpty: Bool { get }
//    var myList: MyList! { get }
//}
//
//// MARK: - ViewModel protocol
//
//private typealias ViewModel = ViewModelInput & ViewModelOutput

// MARK: - HomeViewModel class

final class HomeViewModel: ViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    var coordinator: HomeViewCoordinator?
    
    private(set) weak var authService: AuthService!
    private(set) var useCase: HomeUseCase
    private(set) var actions: HomeViewModelActions!
    
    private var sectionsTask: Cancellable? { willSet { sectionsTask?.cancel() } }
    private var mediaTask: Cancellable? { willSet { mediaTask?.cancel() } }
    
    fileprivate(set) var sections: [Section] = []
    fileprivate(set) var media: [Media] = []
    fileprivate(set) var tableViewState: Observable<HomeTableViewDataSource.State> = Observable(.all)
    fileprivate(set) var presentedDisplayMedia: Observable<Media?> = Observable(nil)
    fileprivate var isEmpty: Bool { sections.isEmpty }
    fileprivate(set) var myList: MyList!
    private var displayMediaCache: [HomeTableViewDataSource.State: Media] = [:]
    
    init(authService: AuthService, useCase: HomeUseCase) {
        self.authService = authService
        self.useCase = useCase
        self.actions = HomeViewModelActions(
            navigationViewDidAppear: { [weak self] in
                guard let homeViewController = self?.coordinator?.viewController else { return }
                homeViewController.navigationViewTopConstraint.constant = 0.0
                homeViewController.navigationView.alpha = 1.0
                homeViewController.view.animateUsingSpring(withDuration: 0.66, withDamping: 1.0, initialSpringVelocity: 1.0)
            }, presentMediaDetails: { [weak self] section, media in
                self?.coordinator?.presentDetailViewController(section: section, media: media)
            })
    }
    
    deinit {
        myList = nil
        mediaTask = nil
        sectionsTask = nil
    }
    
    func reloadMyList() {
        guard
            let coordinator = coordinator,
            coordinator.viewController!.tableView.numberOfSections > 0,
            let myListIndex = HomeTableViewDataSource.Index(rawValue: 6)
        else { return }
        let section = section(at: .myList)
        filter(section: section)
        let index = IndexSet(integer: myListIndex.rawValue)
        coordinator.viewController!.tableView.reloadSections(index, with: .automatic)
    }
}

// MARK: - ViewModelInput implementation

extension HomeViewModel {
    
    func viewWillLoad() {
        /// Invokes request for sections data.
        fetchSections()
    }
    
    fileprivate func viewDidLoad() {
        /// Invokes navigation bar presentation.
        actions?.navigationViewDidAppear()
        /// Invokes tableview presentation.
        tableViewState.value = .all
        /// Creates an instance of `MyList`.
        myList = MyList(with: self)
        myList.viewDidLoad()
    }
    
    fileprivate func fetchSections() {
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
    
    fileprivate func fetchMedia() {
        mediaTask = useCase.execute(
            for: MediaResponse.GET.Many.self,
            request: MediaRequestDTO.self,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(response) = result {
                    self.media = response.data
                    self.viewDidLoad()
                }
            })
    }
    
    func filter(section: Section) {
        guard !isEmpty else { return }
        
        if section.id == 6 {
            var media = myList.list.value
            switch tableViewState.value {
            case .all:
                break
            case .series:
                media = media.filter { $0.type == .series }
            case .films:
                media = media.filter { $0.type == .film }
            }
            sections[section.id].media = media.toArray()
        }
    }
    
    func filter(sections: [Section]) {
        guard !isEmpty else { return }
        
        HomeTableViewDataSource.Index.allCases.forEach { index in
            switch index {
            case .ratable:
                var media = media
                switch tableViewState.value {
                case .all:
                    media = media
                        .sorted { $0.rating > $1.rating }
                        .filter { $0.rating > 7.5 }
                        .slice(10)
                case .series:
                    media = media
                        .filter { $0.type == .series }
                        .sorted { $0.rating > $1.rating }
                        .filter { $0.rating > 7.5 }
                        .slice(10)
                case .films:
                    media = media
                        .filter { $0.type == .film }
                        .sorted { $0.rating > $1.rating }
                        .filter { $0.rating > 7.5 }
                        .slice(10)
                }
                sections[index.rawValue].media = media
            case .resumable:
                var media = media
                switch tableViewState.value {
                case .all:
                    media = media.shuffled()
                case .series:
                    media = media
                        .shuffled()
                        .filter { $0.type == .series }
                case .films:
                    media = media
                        .shuffled()
                        .filter { $0.type == .film }
                }
                sections[index.rawValue].media = media
            case .myList:
                guard let myList = myList else { return }
                var media = myList.list.value
                switch tableViewState.value {
                case .all:
                    break
                case .series:
                    media = media.filter { $0.type == .series }
                case .films:
                    media = media.filter { $0.type == .film }
                }
                sections[index.rawValue].media = media.toArray()
            case .action, .sciFi,
                    .crime, .thriller,
                    .adventure, .comedy,
                    .drama, .horror,
                    .anime, .familyNchildren,
                    .documentary:
                switch tableViewState.value {
                case .all:
                    sections[index.rawValue].media = media
                        .shuffled()
                        .filter { $0.genres.contains(sections[index.rawValue].title) }
                case .series:
                    sections[index.rawValue].media = media
                        .shuffled()
                        .filter { $0.type == .series }
                        .filter { $0.genres.contains(sections[index.rawValue].title) }
                case .films:
                    sections[index.rawValue].media = media
                        .shuffled()
                        .filter { $0.type == .film }
                        .filter { $0.genres.contains(sections[index.rawValue].title) }
                }
            case .blockbuster:
                let value = Float(7.5)
                switch tableViewState.value {
                case .all:
                    sections[index.rawValue].media = media
                        .filter { $0.rating > value }
                case .series:
                    sections[index.rawValue].media = media
                        .filter { $0.type == .series }
                        .filter { $0.rating > value }
                case .films:
                    sections[index.rawValue].media = media
                        .filter { $0.type == .film }
                        .filter { $0.rating > value }
                }
            default: break
            }
        }
    }
    
    func section(at index: HomeTableViewDataSource.Index) -> Section {
        sections[index.rawValue]
    }
    
    fileprivate func generateMedia(for state: HomeTableViewDataSource.State) -> Media {
        guard displayMediaCache[state] == nil else { return displayMediaCache[state]! }
        switch state {
        case .all:
            displayMediaCache[state] = media.randomElement()
        case .series:
            displayMediaCache[state] = media
                .filter { $0.type == .series }
                .randomElement()!
        case .films:
            displayMediaCache[state] = media
                .filter { $0.type == .film }
                .randomElement()!
        }
        return displayMediaCache[state]!
    }
    
    func presentedDisplayMediaDidChange() {
        presentedDisplayMedia.value = generateMedia(for: tableViewState.value)
    }
}

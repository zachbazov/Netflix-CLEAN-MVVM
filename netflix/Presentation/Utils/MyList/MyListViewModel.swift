//
//  MyListViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/12/2022.
//

import Foundation

// MARK: - MyListViewModel Type

final class MyListViewModel {
    
    // MARK: Properties
    
    weak var coordinator: HomeViewCoordinator?
    private let user: UserDTO
    private let homeUseCase: HomeUseCase
    let list: Observable<Set<Media>> = Observable([])
    let section: Section
    private var task: Cancellable? { willSet { task?.cancel() } }
    
    // MARK: Initializer
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator
        self.user = Application.current.authService.user ?? .init()
        self.homeUseCase = viewModel.useCase
        self.section = viewModel.section(at: .myList)
    }
    
    // MARK: Deinitializer
    
    deinit {
        coordinator = nil
        task = nil
    }
}

// MARK: - HomeUseCase Implementation

extension MyListViewModel {
    func fetchList() {
        let requestDTO = ListRequestDTO.GET(user: user)
        task = homeUseCase.execute(
            for: ListResponseDTO.GET.self,
            request: requestDTO,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(responseDTO) = result {
                    if let data = responseDTO.data.first {
                        self.list.value = data.toDomain().media.toSet()
                        self.section.media = self.list.value.toArray()
                    }
                }
                if case let .failure(error) = result { print(error) }
            })
    }
    
    fileprivate func updateList() {
        guard let media = section.media as [Media]? else { return }
        let requestDTO = ListRequestDTO.PATCH(user: user._id!,
                                              media: media.toObjectIDs())
        task = homeUseCase.execute(
            for: ListResponseDTO.PATCH.self,
            request: requestDTO,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    self.section.media = self.list.value.toArray()
                }
                if case let .failure(error) = result { print(error) }
            })
    }
}

// MARK: - Methods

extension MyListViewModel {
    func shouldAddOrRemove(_ media: Media, uponSelection selected: Bool) {
        if selected {
            list.value.remove(media)
            section.media = list.value.toArray()
        } else {
            list.value.insert(media)
            section.media = list.value.toArray()
        }
        
        updateList()
        listDidReload()
    }
    
    func listDidReload() {
        guard coordinator!.viewController!.tableView.numberOfSections > 0,
              let myListIndex = HomeTableViewDataSource.Index(rawValue: 6),
              let section = coordinator!.viewController?.viewModel?.section(at: .myList) else {
            return
        }
        filter(section: section)
        let index = IndexSet(integer: myListIndex.rawValue)
        coordinator!.viewController?.tableView.reloadSections(index, with: .automatic)
    }
    
    func contains(_ media: Media, in list: [Media]) -> Bool {
        return list.contains(media)
    }
    
    func filter(section: Section) {
        let homeViewModel = coordinator!.viewController!.viewModel!
        
        guard !homeViewModel.isEmpty else { return }
        
        if section.id == homeViewModel.section(at: .myList).id {
            var media = list.value
            switch homeViewModel.dataSourceState.value {
            case .all: break
            case .tvShows: media = media.filter { $0.type == .series }
            case .movies: media = media.filter { $0.type == .film }
            }
            homeViewModel.sections[section.id].media = media.toArray()
        }
    }
}

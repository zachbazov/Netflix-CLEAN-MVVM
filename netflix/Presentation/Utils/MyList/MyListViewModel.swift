//
//  MyListViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/12/2022.
//

import Foundation

// MARK: - MyListViewModel Type

final class MyListViewModel {
    weak var coordinator: HomeViewCoordinator?
    
    private let useCase = ListUseCase()
    
    private let user: UserDTO
    let list: Observable<Set<Media>> = Observable([])
    let section: Section
    
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator
        self.user = Application.app.services.authentication.user!
        self.section = viewModel.section(at: .myList)
    }
    
    deinit {
        coordinator = nil
    }
}

// MARK: - HomeUseCase Implementation

extension MyListViewModel {
    func fetchList() {
        let requestDTO = ListHTTPDTO.GET.Request(user: user)
        useCase.repository.task = useCase.request(
            for: ListHTTPDTO.GET.Response.self,
            request: requestDTO,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(responseDTO) = result {
                    self.list.value = responseDTO.data.first!.toDomain().media.toSet()
                    self.section.media = self.list.value.toArray()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func updateList() {
        guard let media = section.media as [Media]? else { return }
        let requestDTO = ListHTTPDTO.PATCH.Request(user: user._id!,
                                                   media: media.toObjectIDs())
        useCase.repository.task = useCase.request(
            for: ListHTTPDTO.PATCH.Response.self,
            request: requestDTO,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    self.section.media = self.list.value.toArray()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "\(error)")
                }
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
            case .tvShows: media = media.filter { $0.type == "series" }
            case .movies: media = media.filter { $0.type == "film" }
            }
            homeViewModel.sections[section.id].media = media.toArray()
        }
    }
}

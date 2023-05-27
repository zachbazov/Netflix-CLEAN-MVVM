//
//  MyListViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 08/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var useCase: ListUseCase { get }
    var user: UserDTO { get }
    var list: Set<Media> { get }
    var section: Section { get }
    
    func sectionWillReload()
    func shouldAddOrRemove(_ media: Media, uponSelection selected: Bool)
    func contains(_ media: Media, in list: [Media]) -> Bool
    func filter(section: Section)
}

// MARK: - MyListViewModel Type

final class MyListViewModel {
    let coordinator: HomeViewCoordinator
    
    fileprivate lazy var useCase: ListUseCase = createUseCase()
    
    fileprivate let user: UserDTO
    
    var list = Set<Media>()
    let section: Section
    
    init() {
        guard let homeController = Application.app.coordinator.tabCoordinator?.home.viewControllers.first as? HomeViewController,
              let homeViewModel = homeController.viewModel
        else { fatalError() }
        
        guard let coordinator = homeViewModel.coordinator else { fatalError() }
        self.coordinator = coordinator
        
        let authentication = Application.app.services.authentication
        guard let user = authentication.user else { fatalError() }
        self.user = user
        
        self.section = homeViewModel.section(at: .myList)
    }
}

// MARK: - ViewModelProtocol Implementation

extension MyListViewModel: ViewModelProtocol {
    fileprivate func updateList() {
        if #available(iOS 13.0, *) {
            Task {
                await listWillUpdate()
            }
            
            return
        }
        
        listWillUpdate()
    }
    
    func sectionWillReload() {
        guard let homeController = coordinator.viewController,
              homeController.tableView?.numberOfSections ?? .zero > 0,
              let myListIndex = MediaTableViewDataSource.Index(rawValue: 6),
              let section = homeController.viewModel?.section(at: .myList)
        else { return }
        
        filter(section: section)
        
        let index = IndexSet(integer: myListIndex.rawValue)
        homeController.tableView?.reloadSections(index, with: .automatic)
    }
    
    func shouldAddOrRemove(_ media: Media, uponSelection selected: Bool) {
        if selected {
            list.remove(media)
            section.media = list.toArray()
        } else {
            list.insert(media)
            section.media = list.toArray()
        }
        
        updateList()
        sectionWillReload()
    }
    
    func contains(_ media: Media, in list: [Media]) -> Bool {
        return list.contains(media)
    }
    
    func filter(section: Section) {
        guard let homeController = coordinator.viewController,
              let homeViewModel = homeController.viewModel,
              !homeViewModel.isSectionsEmpty
        else { return }
        
        if section.id == homeViewModel.section(at: .myList).id {
            var media: Set<Media> = list
            
            switch homeViewModel.dataSourceState.value {
            case .all: break
            case .tvShows: media = media.filter { $0.type == "series" }
            case .movies: media = media.filter { $0.type == "film" }
            }
            
            homeViewModel.sections[section.id].media = media.toArray()
        }
    }
}

// MARK: - DataProviderProtocol Type

private protocol DataProviderProtocol {
    func listWillLoad()
    func listWillUpdate()
    func listWillLoad() async
    func listWillUpdate() async
}

// MARK: - DataProviderProtocol Implementation

extension MyListViewModel: DataProviderProtocol {
    func listWillLoad() {
        guard self.list.isEmpty else {
            dataDidLoad()
            
            return
        }
        
        let request = ListHTTPDTO.GET.Request(user: user)
        
        useCase.repository.task = useCase.request(
            endpoint: .getList,
            for: ListHTTPDTO.GET.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    guard let media = response.data.first?.toDomain().media else { return }
                    
                    self.list = media.toSet()
                    
                    self.section.media = media
                    
                    self.dataDidLoad()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func listWillUpdate() {
        guard let media = section.media as [Media]? else { return }
        
        let request = ListHTTPDTO.PATCH.Request(user: user._id!, media: media.toObjectIDs())
        
        useCase.repository.task = useCase.request(
            endpoint: .updateList,
            for: ListHTTPDTO.PATCH.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.section.media = self.list.toArray()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func listWillLoad() async {
        guard self.list.isEmpty else {
            dataDidLoad()
            
            return
        }
        
        let request = ListHTTPDTO.GET.Request(user: user)
        let response = await useCase.request(endpoint: .getList, for: ListHTTPDTO.GET.Response.self, request: request)
        
        guard let list = response?.data.first?.media.toDomain() else { return }
        
        self.list = list.toSet()
        self.section.media = list
        
        dataDidLoad()
    }
    
    fileprivate func listWillUpdate() async {
        guard let id = user._id else { return }
        
        let request = ListHTTPDTO.PATCH.Request(user: id, media: section.media.toObjectIDs())
        let response = await useCase.request(endpoint: .updateList, for: ListHTTPDTO.PATCH.Response.self, request: request)
        
        guard let _ = response else { return }
        
        section.media = list.toArray()
    }
}

// MARK: - Private Implementation

extension MyListViewModel {
    private func dataDidLoad() {
        mainQueueDispatch { [weak self] in
            guard let self = self,
                  let dataSource = self.coordinator.viewController?.dataSource,
                  let panelView = dataSource.showcaseCell?.showcaseView?.panelView
            else { return }
            
            panelView.selectIfNeeded()
        }
    }
}

// MARK: - Private Implementation

extension MyListViewModel {
    private func createUseCase() -> ListUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = ListRepository(dataTransferService: dataTransferService)
        return ListUseCase(repository: repository)
    }
}

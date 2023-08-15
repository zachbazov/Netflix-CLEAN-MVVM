//
//  MyList.swift
//  netflix
//
//  Created by Zach Bazov on 14/11/2022.
//

import UIKit

// MARK: - MyList Type

final class MyList {
    private lazy var useCase: ListUseCase = createUseCase()
    
    var list = Set<Media>()
    
    var user: UserDTO?
    var section: Section?
    
    weak var viewModel: HomeViewModel? {
        didSet { activate() }
    }
    
    func activate() {
        let auth = Application.app.services.auth
        
        mainQueueDispatch { [weak self] in
            self?.user = auth.user
            self?.section = self?.viewModel?.section(at: .myList)
        }
    }
    
    private func createUseCase() -> ListUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = ListRepository(dataTransferService: dataTransferService)
        return ListUseCase(repository: repository)
    }
    
    private func dataDidLoad() {
        mainQueueDispatch { [weak self] in
            guard let controller = self?.viewModel?.coordinator?.viewController,
                  let dataSource = controller.dataSource,
                  let panelView = dataSource.showcaseCell?.showcaseView?.panelView
            else { return }
            
            panelView.selectIfNeeded()
        }
    }
    
    fileprivate func updateList() {
        listWillUpdate()
    }
    
    func sectionWillReload() {
        guard let homeController = viewModel?.coordinator?.viewController,
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
            
            section?.media = list.toArray()
        } else {
            list.insert(media)
            
            section?.media = list.toArray()
        }
        
        updateList()
        sectionWillReload()
    }
    
    func contains(_ media: Media, in list: [Media]) -> Bool {
        return list.contains(media)
    }
    
    func filter(section: Section) {
        guard let homeController = viewModel?.coordinator?.viewController,
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
    
    func fetchList() {
        guard self.list.isEmpty else {
            dataDidLoad()
            
            return
        }
        
        guard let user = user else { return }
        
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
                    
                    self.section?.media = media
                    
                    self.dataDidLoad()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func listWillUpdate() {
        guard let media = section?.media as [Media]?,
              let user = user
        else { return }
        
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
                    self.section?.media = self.list.toArray()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
}

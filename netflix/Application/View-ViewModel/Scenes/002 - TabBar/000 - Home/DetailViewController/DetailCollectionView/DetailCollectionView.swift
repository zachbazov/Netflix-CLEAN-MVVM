//
//  DetailCollectionView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var collectionView: UICollectionView { get }
    var dataSource: DetailCollectionViewDataSource<Mediable>? { get }
    
    func createCollectionView() -> UICollectionView
    func createLayout(for state: DetailNavigationView.State) -> CollectionViewLayout
    func createDataSource(for state: DetailNavigationView.State) -> DetailCollectionViewDataSource<Mediable>?
    
    func dataSourceDidChange()
    func reload()
}

// MARK: - DetailCollectionView Type

final class DetailCollectionView: View<DetailCollectionViewModel> {
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: DetailCollectionViewDataSource<Mediable>?
    
    /// Create a detail collection view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        
        self.viewModel = DetailCollectionViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    override func dataWillLoad() {
        loadEpisodes()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillBindObservers()
        dataWillLoad()
    }
    
    override func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: self)
            .constraintToSuperview(self)
    }
    
    override func viewWillBindObservers() {
        viewModel?.season.observe(on: self) { [weak self] season in
            guard let self = self else { return }
            
            self.reload()
        }
        
        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.reload()
        }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.season.remove(observer: self)
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        dataSource = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension DetailCollectionView: ViewProtocol {
    fileprivate func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .black
        collectionView.registerNib(StandardCollectionViewCell.self,
                                   EpisodeCollectionViewCell.self,
                                   TrailerCollectionViewCell.self)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 16.0, left: .zero, bottom: .zero, right: .zero)
        return collectionView
    }
    
    fileprivate func createLayout(for state: DetailNavigationView.State) -> CollectionViewLayout {
        switch state {
        case .episodes:
            return CollectionViewLayout(layout: .descriptive, scrollDirection: .vertical)
        case .trailers:
            return CollectionViewLayout(layout: .trailer, scrollDirection: .vertical)
        case .similarContent:
            return CollectionViewLayout(layout: .detail, scrollDirection: .vertical)
        }
    }
    
    fileprivate func createDataSource(for state: DetailNavigationView.State) -> DetailCollectionViewDataSource<Mediable>? {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel else { fatalError() }
        
        switch state {
        case .episodes:
            let episodes = self.viewModel.season.value.episodes
            return DetailCollectionViewDataSource(collectionView: collectionView, items: episodes, with: viewModel)
        case .trailers:
            guard let trailers = viewModel.media?.resources.trailers.toDomain() else { fatalError() }
            return DetailCollectionViewDataSource(collectionView: collectionView, items: trailers, with: viewModel)
        case .similarContent:
            guard let media = viewModel.section?.media else { fatalError() }
            return DetailCollectionViewDataSource(collectionView: collectionView, items: media, with: viewModel)
        }
    }
    
    func dataSourceDidChange() {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel,
              let controller = viewModel.coordinator?.viewController,
              let state = controller.dataSource?.navigationCell?.navigationView?.viewModel.state.value
        else { return }
        
        let layout = createLayout(for: state)
        let dataSource = createDataSource(for: state)
        
        self.dataSource = dataSource
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
    
    fileprivate func reload() {
        guard let controller = self.viewModel?.coordinator.viewController,
              let dataSource = controller.dataSource
        else { return }
        
        mainQueueDispatch {
            dataSource.reloadData(at: .collection)
        }
    }
}

// MARK: - State Type

extension DetailCollectionView {
    enum State {
        case series
        case film
        case similarContent
    }
}

// MARK: - Private Presentation Implementation

extension DetailCollectionView {
    private func loadEpisodes() {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel,
              let dataSource = viewModel.coordinator?.viewController?.dataSource,
              let state = dataSource.navigationCell?.navigationView?.viewModel.state.value
        else { return }
        
        if case .episodes = state {
            let cellViewModel = EpisodeCollectionViewCellViewModel(with: viewModel)
            let requestDTO = SeasonHTTPDTO.Request(slug: cellViewModel.media.slug, season: 1)
            
            self.viewModel?.seasonDidLoad(request: requestDTO) {}
        }
    }
}

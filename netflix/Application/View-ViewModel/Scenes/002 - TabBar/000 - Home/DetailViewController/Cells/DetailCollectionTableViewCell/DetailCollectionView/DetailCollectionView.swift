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
    var dataSource: DetailCollectionViewDataSource<Mediable>! { get }
    var layout: CollectionViewLayout! { get }
    
    func createCollectionView() -> UICollectionView
    func dataSourceDidChange()
}

// MARK: - DetailCollectionView Type

final class DetailCollectionView: View<DetailViewModel> {
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: DetailCollectionViewDataSource<Mediable>!
    fileprivate var layout: CollectionViewLayout!
    
    /// Create a detail collection view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        parent.addSubview(self)
        self.viewModel = viewModel
        self.constraintToSuperview(parent)
        self.collectionView.constraintToSuperview(self)
        self.dataWillLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        layout = nil
        dataSource = nil
    }
    
    override func dataWillLoad() {
        if viewModel.navigationViewState.value == .episodes {
            let cellViewModel = EpisodeCollectionViewCellViewModel(with: viewModel)
            let requestDTO = SeasonHTTPDTO.Request(slug: cellViewModel.media.slug, season: 1)
            
            viewModel.seasonDidLoad(request: requestDTO) { [weak self] in
                self?.dataSourceDidChange()
            }
        }
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
        addSubview(collectionView)
        return collectionView
    }
    
    func dataSourceDidChange() {
        layout = nil
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        switch viewModel.navigationViewState.value {
        case .episodes:
            guard let episodes = viewModel.season.value?.episodes else { return }
            dataSource = DetailCollectionViewDataSource(collectionView: collectionView, items: episodes, with: viewModel)
            layout = CollectionViewLayout(layout: .descriptive, scrollDirection: .vertical)
            collectionView.setCollectionViewLayout(layout, animated: false)
        case .trailers:
            guard let trailers = viewModel.media?.resources.trailers.toDomain() as [Trailer]? else { return }
            dataSource = DetailCollectionViewDataSource(collectionView: collectionView, items: trailers, with: viewModel)
            layout = CollectionViewLayout(layout: .trailer, scrollDirection: .vertical)
            collectionView.setCollectionViewLayout(layout, animated: false)
        default:
            guard let media = viewModel.section?.media as [Media]? else { return }
            dataSource = DetailCollectionViewDataSource(collectionView: collectionView, items: media, with: viewModel)
            layout = CollectionViewLayout(layout: .detail, scrollDirection: .vertical)
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
        
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
}

//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - CollectionViewCell Type

class CollectionViewCell<T>: UICollectionViewCell where T: ViewModel {
    var viewModel: T!
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    class func create(on collectionView: UICollectionView,
                      reuseIdentifier: String,
                      section: Section?,
                      for indexPath: IndexPath) -> PosterCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as? PosterCollectionViewCell,
              let section = section
        else { fatalError() }
        
        let media = section.media[indexPath.row]
        let cellViewModel = PosterCollectionViewCellViewModel(media: media)
        
        cell.viewModel = cellViewModel
        cell.indexPath = indexPath
        cell.viewDidLoad()
        
        return cell
    }
    
    class func create<U>(
        of type: U.Type,
        on collectionView: UICollectionView,
        for indexPath: IndexPath,
        with viewModel: DetailViewModel) -> U {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: type),
                for: indexPath) as? U
            else { fatalError() }
            
            switch cell {
            case let cell as EpisodeCollectionViewCell:
                cell.viewModel = cell.createViewModel(for: cell, with: viewModel)
                cell.indexPath = indexPath
                cell.viewDidLoad()
            case let cell as TrailerCollectionViewCell:
                cell.viewModel = cell.createViewModel(for: cell, with: viewModel)
                cell.indexPath = indexPath
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
    
    deinit {
        indexPath = nil
        representedIdentifier = nil
        viewModel = nil
        
        removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        indexPath = nil
        representedIdentifier = nil
        viewModel = nil
    }
    
    func createViewModel<U>(for type: U, with viewModel: DetailViewModel) -> T? {
        switch type {
        case is EpisodeCollectionViewCell:
            return EpisodeCollectionViewCellViewModel(with: viewModel) as? T
        case is TrailerCollectionViewCell:
            return TrailerCollectionViewCellViewModel(with: viewModel.media) as? T
        default:
            return nil
        }
    }
    
    func viewDidLoad() {}
    func viewWillDeploySubviews() {}
    func viewDidDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewHierarchyDidConfigure() {}
    func viewWillConfigure() {}
    func viewDidConfigure() {}
    
    func viewWillDeallocate() {}
    func viewDidDeallocate() {}
    
    func dataWillLoad(completion: (() -> Void)?) {}
    func loadResources(_ completion: (() -> Void)?) {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionViewCell: ViewLifecycleBehavior {}

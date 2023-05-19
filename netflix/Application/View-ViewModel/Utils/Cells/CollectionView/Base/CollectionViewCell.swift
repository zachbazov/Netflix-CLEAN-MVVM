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
    
    class func create(
        on collectionView: UICollectionView,
        for indexPath: IndexPath,
        with viewModel: SearchViewModel) -> SearchCollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
                for: indexPath) as? SearchCollectionViewCell,
                  let media = viewModel.items.value[indexPath.row].media
            else { fatalError() }
            
            cell.viewModel = SearchCollectionViewCellViewModel(media: media)
            cell.representedIdentifier = cell.viewModel.slug as NSString
            cell.viewDidLoad()
            
            return cell
        }
    
    class func create(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        with viewModel: AccountViewModel) -> ProfileCollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier,
                for: indexPath) as? ProfileCollectionViewCell
            else { fatalError() }
            
            let model = viewModel.profiles.value[indexPath.row]
            
            cell.accountViewModel = viewModel
            cell.viewModel = ProfileCollectionViewCellViewModel(with: model)
            cell.indexPath = indexPath
            cell.viewDidLoad()
            
            return cell
        }
    
    class func create<U>(
        of type: U.Type,
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        with viewModel: AccountViewModel) -> U {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: U.self),
                for: indexPath) as? U
            else { fatalError() }
            
            switch cell {
            case let cell as NotificationCollectionViewCell:
                let myList = MyList.shared
                let media = myList.viewModel.list.toArray()
                let model = media[indexPath.row]
                
                cell.representedIdentifier = model.slug as NSString
                cell.viewModel = NotificationCollectionViewCellViewModel(media: model)
                cell.indexPath = indexPath
                cell.viewDidLoad()
            default: break
            }
            
            return cell
        }
    
    class func create(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        with viewModel: NewsViewModel) -> NewsCollectionViewCell {
            guard let view = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsCollectionViewCell.reuseIdentifier,
                for: indexPath) as? NewsCollectionViewCell
            else { fatalError() }
            
            let cellViewModel = viewModel.items.value[indexPath.row]
            
            view.representedIdentifier = cellViewModel.media.slug as NSString
            view.viewModel = NewsCollectionViewCellViewModel(with: cellViewModel.media)
            view.indexPath = indexPath
            view.viewDidLoad()
            
            return view
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
    
    func dataWillLoad() {}
    func dataDidLoad() {}
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

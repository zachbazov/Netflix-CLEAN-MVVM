//
//  Cell.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - Cell Type

class Cell<T>: UICollectionViewCell where T: ViewModel {
    var viewModel: T!
    
    var indexPath: IndexPath!
    
    class func create<U>(
        of type: U.Type,
        on collectionView: UICollectionView,
        for indexPath: IndexPath,
        with viewModel: DetailViewModel) -> U {
            guard let view = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: type),
                for: indexPath) as? U
            else { fatalError() }
            
            switch view {
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
            
            return view
        }
    
    deinit {
        indexPath = nil
        viewModel = nil
        
        removeFromSuperview()
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
    func viewWillConfigure() {}
    func viewDidConfigure() {}
    
    func dataWillLoad(completion: (() -> Void)?) {}
    func loadResources(_ completion: (() -> Void)?) {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension Cell: ViewLifecycleBehavior {}

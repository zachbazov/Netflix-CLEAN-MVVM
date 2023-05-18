//
//  HomeCollectionCell.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - HomeCollectionCell Type

class HomeCollectionCell<T>: UICollectionViewCell where T: ViewModel {
    var viewModel: T!
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    class func create(on collectionView: UICollectionView,
                      reuseIdentifier: String,
                      section: Section?,
                      for indexPath: IndexPath) -> CollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell,
              let section = section
        else { fatalError() }
        
        let media = section.media[indexPath.row]
        let cellViewModel = CollectionViewCellViewModel(media: media)
        
        cell.viewModel = cellViewModel
        cell.indexPath = indexPath
        cell.representedIdentifier = media.slug as NSString
        
        cell.viewDidLoad(media: media, with: cellViewModel)
        
        return cell
    }
    
    deinit {
        indexPath = nil
        representedIdentifier = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension HomeCollectionCell: ViewLifecycleBehavior {}

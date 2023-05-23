//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - CollectionViewCellResourcing Type

private protocol CollectionViewCellResourcing {
    func loadUsingAsyncAwait()
    func loadUsingAsync()
    func loadUsingDispatchGroup()
    
    func resourceWillLoad(for url: URL, withIdentifier identifier: NSString, _ completion: @escaping () -> Void)
    func resourceWillLoad(for url: URL, withIdentifier identifier: String) async
}

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func setPoster(_ image: UIImage)
    func setLogo(_ image: UIImage)
    func setTitle(_ text: String)
    func setSubject(_ text: String)
    func setPlaceholder(_ text: String)
    func setTimestamp(_ text: String)
    func setDescription(_ text: String)
    func setEstimatedTimeTillAir(_ text: String)
    func setMediaType(_ text: String)
    func setGenres(_ attributedString: NSMutableAttributedString)
    
    func setLogoAlignment()
    func hidePlaceholder()
}

// MARK: - CollectionViewCell Type

class CollectionViewCell<T>: UICollectionViewCell where T: ViewModel {
    var viewModel: T!
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    let imageService = AsyncImageService.shared
    
    class func create<U, CVM>(of type: U.Type,
                              on collectionView: UICollectionView,
                              reuseIdentifier: String? = nil,
                              section: Section? = nil,
                              for indexPath: IndexPath,
                              with viewModel: CVM? = Void) -> U {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier ?? String(describing: type),
                                                            for: indexPath) as? U
        else { fatalError() }
        
        switch cell {
        case let cell as PosterCollectionViewCell:
            guard let section = section else { fatalError() }
            
            let media = section.media[indexPath.row]
            
            cell.viewModel = PosterCollectionViewCellViewModel(media: media)
            cell.representedIdentifier = media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as ProfileCollectionViewCell:
            guard let viewModel = viewModel as? AccountViewModel else { fatalError() }
            
            let model = viewModel.profiles.value[indexPath.row]
            
            cell.viewModel = ProfileCollectionViewCellViewModel(with: model)
            cell.accountViewModel = viewModel
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as AccountMenuNotificationCollectionViewCell:
            let myList = MyList.shared
            let media = myList.viewModel.list.toArray()
            let model = media[indexPath.row]
            
            cell.viewModel = AccountMenuNotificationCollectionViewCellViewModel(media: model)
            cell.representedIdentifier = model.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as SearchCollectionViewCell:
            guard let viewModel = viewModel as? SearchViewModel,
                  let media = viewModel.items.value[indexPath.row].media
            else { fatalError() }
            
            cell.viewModel = SearchCollectionViewCellViewModel(media: media)
            cell.representedIdentifier = media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as EpisodeCollectionViewCell:
            guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
            
            cell.viewModel = EpisodeCollectionViewCellViewModel(with: viewModel)
            cell.representedIdentifier = cell.viewModel.media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as TrailerCollectionViewCell:
            guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
            
            cell.viewModel = TrailerCollectionViewCellViewModel(with: viewModel.media)
            cell.representedIdentifier = cell.viewModel.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as NewsCollectionViewCell:
            guard let viewModel = viewModel as? NewsViewModel else { fatalError() }
            
            let media = viewModel.items.value[indexPath.row].media
            
            cell.viewModel = NewsCollectionViewCellViewModel(with: media)
            cell.representedIdentifier = cell.viewModel.media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        default: break
        }
        
        return cell
    }
    
    deinit {
        representedIdentifier = nil
        indexPath = nil
        viewModel = nil
        
        removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        representedIdentifier = nil
        indexPath = nil
        viewModel = nil
    }
    
    // MARK: ViewLifecycleBehavior Implementation
    
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
    
    // MARK: ViewProtocol Implementation
    
    func setPoster(_ image: UIImage) {}
    func setLogo(_ image: UIImage) {}
    func setTitle(_ text: String) {}
    func setSubject(_ text: String) {}
    func setPlaceholder(_ text: String) {}
    func setTimestamp(_ text: String) {}
    func setDescription(_ text: String) {}
    func setEstimatedTimeTillAir(_ text: String) {}
    func setMediaType(_ text: String) {}
    func setGenres(_ attributedString: NSMutableAttributedString) {}
    
    func setLogoAlignment() {}
    func hidePlaceholder() {}
    
    // MARK: CollectionViewCellResourcing Implementation
    
    func loadUsingAsyncAwait() {}
    func loadUsingAsync() {}
    func loadUsingDispatchGroup() {}
    
    func resourceWillLoad(for url: URL, withIdentifier identifier: NSString, _ completion: @escaping () -> Void) {}
    func resourceWillLoad(for url: URL, withIdentifier identifier: String) async {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension CollectionViewCell: ViewProtocol {}

// MARK: - CollectionViewCellResourcing Implementation

extension CollectionViewCell: CollectionViewCellResourcing {}

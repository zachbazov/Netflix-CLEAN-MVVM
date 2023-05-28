//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - CollectionViewCellResourcing Type

protocol CollectionViewCellResourcing {
    func loadUsingAsyncAwait()
    func loadUsingAsync()
    func loadUsingDispatchGroup()
    
    func resourceWillLoad(for url: URL, withIdentifier identifier: NSString, _ completion: @escaping () -> Void)
    func resourceWillLoad(for url: URL, withIdentifier identifier: String) async
}

// MARK: - CollectionViewCellResourcing Implementation

extension CollectionViewCellResourcing {
    func loadUsingAsyncAwait() {}
    func loadUsingAsync() {}
    func loadUsingDispatchGroup() {}
    
    func resourceWillLoad(for url: URL, withIdentifier identifier: NSString, _ completion: @escaping () -> Void) {}
    func resourceWillLoad(for url: URL, withIdentifier identifier: String) async {}
}

// MARK: - CollectionViewCellConfiguring Type

protocol CollectionViewCellConfiguring {
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

// MARK: - CollectionViewCellConfiguring Implementation

extension CollectionViewCellConfiguring {
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
}

// MARK: - CollectionViewCell Type

protocol CollectionViewCell: UICollectionViewCell,
                             ViewLifecycleBehavior,
                             DataLoadable,
                             CollectionViewCellResourcing,
                             CollectionViewCellConfiguring {
    associatedtype ViewModelType: ViewModel
    
    var viewModel: ViewModelType! { get set }
    var representedIdentifier: NSString! { get set }
    var indexPath: IndexPath! { get set }
}

// MARK: - CollectionViewCell Implementation

extension CollectionViewCell {
    static func create<U, CVM>(of type: U.Type,
                              on collectionView: UICollectionView,
                              reuseIdentifier: String? = nil,
                              section: Section? = nil,
                              for indexPath: IndexPath,
                              with viewModel: CVM? = Void) -> U where U: UICollectionViewCell {
        
        collectionView.register(U.nib, forCellWithReuseIdentifier: U.reuseIdentifier)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier ?? String(describing: type),
                                                            for: indexPath) as? U
        else { fatalError() }
        
        switch cell {
        case let cell as MediaCollectionViewCell:
            guard let section = section else { fatalError() }
            
            let media = section.media[indexPath.row]
            
            cell.viewModel = MediaCollectionViewCellViewModel(media: media)
            cell.representedIdentifier = media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as AccountProfileCollectionViewCell:
            guard let viewModel = viewModel as? AccountViewModel else { fatalError() }
            
            let model = viewModel.profiles.value[indexPath.row]
            
            cell.viewModel = AccountProfileCollectionViewCellViewModel(with: model)
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
            
            cell.viewModel = DetailCollectionViewCellViewModel(with: viewModel)
            cell.representedIdentifier = cell.viewModel.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case let cell as TrailerCollectionViewCell:
            guard let viewModel = viewModel as? DetailViewModel else { fatalError() }
            
            cell.viewModel = DetailCollectionViewCellViewModel(with: viewModel)
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
        case let cell as ProfileCollectionViewCell:
            guard let viewModel = viewModel as? ProfileViewModel else { fatalError() }
            
            let model = viewModel.profiles[indexPath.row]
            
            cell.tag = indexPath.row
            cell.profileViewModel = viewModel
            cell.viewModel = ProfileCollectionViewCellViewModel(with: model)
            cell.representedIdentifier = cell.viewModel.name as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        default: break
        }
        
        return cell
    }
}

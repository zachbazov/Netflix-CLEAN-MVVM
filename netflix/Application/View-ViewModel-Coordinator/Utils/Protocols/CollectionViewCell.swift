//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - CollectionViewCellEditable Type

protocol CollectionViewCellEditable {
    var editOverlayView: EditOverlayView? { get }
    
    func editMode(_ active: Bool)
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
                              with viewModel: CVM?) -> U where U: UICollectionViewCell {
        
        collectionView.register(U.nib, forCellWithReuseIdentifier: U.reuseIdentifier)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier ?? String(describing: type),
                                                            for: indexPath) as? U
        else { fatalError() }
        
        switch (cell, viewModel) {
        case (let cell as MediaCollectionViewCell, _ as HomeViewModel):
            guard let section = section else { fatalError() }
            
            let media = section.media[indexPath.row]
            
            cell.viewModel = MediaCollectionViewCellViewModel(media: media)
            cell.representedIdentifier = media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as MediaCollectionViewCell, _ as MyNetflixViewModel):
            guard let media = section?.media else { fatalError() }
            
            let model = media[indexPath.row]
            
            cell.viewModel = MediaCollectionViewCellViewModel(media: model)
            cell.representedIdentifier = model.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as MediaCollectionViewCell, _ as MyListViewModel):
            guard let media = section?.media else { fatalError() }
            
            let model = media[indexPath.row]
            
            cell.viewModel = MediaCollectionViewCellViewModel(media: model)
            cell.representedIdentifier = model.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as AccountProfileCollectionViewCell, let controllerViewModel as AccountViewModel):
            let model = controllerViewModel.profiles.value[indexPath.row]
            
            cell.viewModel = AccountProfileCollectionViewCellViewModel(with: model)
            cell.accountViewModel = controllerViewModel
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as NotificationCollectionViewCell, _):
            let myList = Application.app.services.myList
            let media = myList.list.toArray()
            let model = media[indexPath.row]
            
            cell.viewModel = NotificationCollectionViewCellViewModel(media: model)
            cell.representedIdentifier = model.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as SearchCollectionViewCell, let controllerViewModel as SearchViewModel):
            guard let media = controllerViewModel.items.value[indexPath.row].media else { fatalError() }
            
            cell.viewModel = SearchCollectionViewCellViewModel(media: media)
            cell.representedIdentifier = media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as EpisodeCollectionViewCell, let controllerViewModel as DetailViewModel):
            cell.viewModel = DetailCollectionViewCellViewModel(with: controllerViewModel)
            cell.representedIdentifier = cell.viewModel.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as TrailerCollectionViewCell, let controllerViewModel as DetailViewModel):
            cell.viewModel = DetailCollectionViewCellViewModel(with: controllerViewModel)
            cell.representedIdentifier = cell.viewModel.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as NewsCollectionViewCell, let controllerViewModel as NewsViewModel):
            let media = controllerViewModel.items.value[indexPath.row].media
            
            cell.viewModel = NewsCollectionViewCellViewModel(with: media)
            cell.representedIdentifier = cell.viewModel.media.slug as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        case (let cell as ProfileCollectionViewCell, let controllerViewModel as ProfileViewModel):
            let model = controllerViewModel.profiles[indexPath.row]
            
            cell.tag = indexPath.row
            cell.profileViewModel = controllerViewModel
            cell.viewModel = ProfileCollectionViewCellViewModel(with: model)
            cell.representedIdentifier = cell.viewModel.id as NSString
            cell.indexPath = indexPath
            cell.viewDidLoad()
        default: break
        }
        
        return cell
    }
}

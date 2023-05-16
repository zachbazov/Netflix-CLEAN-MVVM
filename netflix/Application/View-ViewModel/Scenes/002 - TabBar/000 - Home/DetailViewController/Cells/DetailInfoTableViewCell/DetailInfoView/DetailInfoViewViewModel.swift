//
//  DetailInfoViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var mediaType: String { get }
    var title: String { get }
    var downloadButtonTitle: String { get }
    var duration: String { get }
    var length: String { get }
    var isHD: Bool { get }
}

// MARK: - DetailInfoViewViewModel Type

struct DetailInfoViewViewModel {
    let mediaType: String
    let title: String
    let downloadButtonTitle: String
    let duration: String
    let length: String
    let isHD: Bool
    
    /// Create a info view view model object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: DetailViewModel) {
        guard let media = viewModel.media else { fatalError() }
        
        guard let type = Media.MediaType(rawValue: media.type) else { fatalError() }
        
        self.mediaType = type == .series ? "S E R I E" : "F I L M"
        
        self.title = media.title
        self.downloadButtonTitle = "Download \(self.title)"
        
        switch type {
        case .series:
            let numberOfSeasons = Int(media.seasons?.count ?? 1)
            self.duration = String(describing: media.duration)
            self.length = String(describing: numberOfSeasons > 1
                                 ? "\(numberOfSeasons) Seasons"
                                 : "\(numberOfSeasons) Season")
        case .film:
            self.duration = media.duration
            self.length = media.length
        default:
            fatalError()
        }
        
        self.isHD = media.isHD
    }
}

// MARK: - ViewModel Implementation

extension DetailInfoViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailInfoViewViewModel: ViewModelProtocol {}

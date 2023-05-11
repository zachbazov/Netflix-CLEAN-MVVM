//
//  ShowcaseViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var slug: String { get }
    var genres: [String] { get }
    var posterImagePath: String { get }
    var posterImageIdentifier: NSString { get }
    var posterImageURL: URL! { get }
    var logoImagePath: String { get }
    var logoImageIdentifier: NSString { get }
    var logoImageURL: URL! { get }
    var attributedGenres: NSMutableAttributedString { get }
    var typeImagePath: String? { get }
    
    mutating func setMediaTypeImage(for media: Media)
}

// MARK: - ShowcaseViewViewModel Type

struct ShowcaseViewViewModel {
    let coordinator: HomeViewCoordinator
    
    let slug: String
    let genres: [String]
    let posterImagePath: String
    let posterImageIdentifier: NSString
    let posterImageURL: URL!
    var logoImagePath: String
    let logoImageIdentifier: NSString
    let logoImageURL: URL!
    var attributedGenres: NSMutableAttributedString
    var typeImagePath: String?
    
    /// Create a view model based on a media object.
    /// - Parameter media: The media object represented on the display view.
    init?(media: Media?, with viewModel: HomeViewModel?) {
        guard let coordinator = viewModel?.coordinator else { return nil }
        self.coordinator = coordinator
        
        guard let media = media else { return nil }
        
        self.slug = media.slug
        self.posterImagePath = media.path(forResourceOfType: PresentedPoster.self) ?? .toBlank()
        self.logoImagePath = .toBlank()
        self.genres = media.genres
        self.attributedGenres = .init()
        self.posterImageIdentifier = .init(string: "poster_\(media.slug)")
        self.logoImageIdentifier = .init(string: "display-logo_\(media.slug)")
        self.logoImagePath = media.path(forResourceOfType: PresentedDisplayLogo.self) ?? .toBlank()
        self.posterImageURL = .init(string: self.posterImagePath)
        self.logoImageURL = .init(string: self.logoImagePath)
        self.attributedGenres = media.attributedString(for: .display)
        
        self.setMediaTypeImage(for: media)
    }
}

// MARK: - ViewModel Implementation

extension ShowcaseViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension ShowcaseViewViewModel: ViewModelProtocol {
    fileprivate mutating func setMediaTypeImage(for media: Media) {
        guard let type = Media.MediaType(rawValue: media.type) else {
            typeImagePath = nil
            
            return
        }
        
        switch type {
        case .series where media.isExclusive:
            typeImagePath = "netflix-series"
        case .film where media.isExclusive:
            typeImagePath = "netflix-film"
        default:
            typeImagePath = nil
        }
    }
}

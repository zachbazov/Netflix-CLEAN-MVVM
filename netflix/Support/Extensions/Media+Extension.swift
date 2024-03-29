//
//  Media+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import Foundation

// MARK: - PresentedLogoAlignment Type

enum PresentedLogoAlignment: String {
    case top
    case midTop = "mid-top"
    case mid
    case midBottom = "mid-bottom"
    case bottom
}

// MARK: - PresentedSearchLogoAlignment Type

enum PresentedSearchLogoAlignment: String {
    case minXminY, minXmidY, minXmaxY
    case midXminY, midXmidY, midXmaxY
    case maxXminY, maxXmidY, maxXmaxY
}

// MARK: - PresentedPoster Type

enum PresentedPoster: String {
    case first = "0"
    case second = "1"
    case third = "2"
    case fourth = "3"
    case fifth = "4"
    case sixth = "5"
}

// MARK: - PresentedLogo Type

enum PresentedLogo: String {
    case first = "0"
    case second = "1"
    case third = "2"
    case fourth = "3"
    case fifth = "4"
    case sixth = "5"
    case seventh = "6"
}

// MARK: - PresentedDisplayLogo Type

enum PresentedDisplayLogo: String {
    case first = "0"
    case second = "1"
    case third = "2"
    case fourth = "3"
    case fifth = "4"
    case sixth = "5"
    case seventh = "6"
}

// MARK: - PresentedSearchLogo Type

enum PresentedSearchLogo: String {
    case first = "0"
    case second = "1"
    case third = "2"
    case fourth = "3"
    case fifth = "4"
    case sixth = "5"
    case seventh = "6"
}

// MARK: - Media + Resource Path Provider

extension Media {
    func path<T>(forResourceOfType type: T.Type) -> String {
        switch type {
        case is PresentedPoster.Type:
            switch PresentedPoster(rawValue: resources.presentedPoster) {
            case .first: return resources.posters[0]
            case .second: return resources.posters[1]
            case .third: return resources.posters[2]
            case .fourth: return resources.posters[3]
            case .fifth: return resources.posters[4]
            case .sixth: return resources.posters[5]
            case nil: return .toBlank()
            }
        case is PresentedLogo.Type:
            switch PresentedLogo(rawValue: resources.presentedLogo) {
            case .first: return resources.logos[0]
            case .second: return resources.logos[1]
            case .third: return resources.logos[2]
            case .fourth: return resources.logos[3]
            case .fifth: return resources.logos[4]
            case .sixth: return resources.logos[5]
            case .seventh: return resources.logos[6]
            case nil: return .toBlank()
            }
        case is PresentedDisplayLogo.Type:
            switch PresentedDisplayLogo(rawValue: resources.presentedDisplayLogo) {
            case .first: return resources.logos[0]
            case .second: return resources.logos[1]
            case .third: return resources.logos[2]
            case .fourth: return resources.logos[3]
            case .fifth: return resources.logos[4]
            case .sixth: return resources.logos[5]
            case .seventh: return resources.logos[6]
            case nil: return .toBlank()
            }
        case is PresentedSearchLogo.Type:
            switch PresentedDisplayLogo(rawValue: resources.presentedSearchLogo) {
            case .first: return resources.logos[0]
            case .second: return resources.logos[1]
            case .third: return resources.logos[2]
            case .fourth: return resources.logos[3]
            case .fifth: return resources.logos[4]
            case .sixth: return resources.logos[5]
            case .seventh: return resources.logos[6]
            case nil: return .toBlank()
            }
        default: return .toBlank()
        }
    }
}

// MARK: - Media + Attributed Genres String

extension Media {
    
    // MARK: Presentor Type
    
    enum Presentor {
        case display
        case news
    }
    
    // MARK: Methods
    
    func attributedString(for presentor: Presentor) -> NSMutableAttributedString {
        guard let symbol = " · " as String?,
              let genres = genres as [String]? else {
            return .init()
        }
        
        let mutableString = NSMutableAttributedString()
        let genresAttributes = presentor == .display
            ? NSAttributedString.displayGenresAttributes
            : NSAttributedString.newsGenresAttributes
        let separatorAttributes = presentor == .display
            ? NSAttributedString.displayGenresSeparatorAttributes
            : NSAttributedString.newsGenresSeparatorAttributes
        let mappedGenres = genres.enumerated().map {
            NSAttributedString(string: $0.element, attributes: genresAttributes) }
        
        for genre in mappedGenres {
            mutableString.append(genre)
            let attributedSeparator = NSAttributedString(string: symbol, attributes: separatorAttributes)
            if genre == mappedGenres.last { continue }
            mutableString.append(attributedSeparator)
        }
        
        return mutableString
    }
}

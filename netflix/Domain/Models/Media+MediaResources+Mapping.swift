//
//  Media.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - Mediable Type

protocol Mediable {
    var id: String? { get }
}

// MARK: - MediaResources Type

struct MediaResources {
    let posters: [String]
    let logos: [String]
    let trailers: [String]
    let displayPoster: String
    let previewPoster: String
    let previewUrl: String
    let presentedPoster: String
    let presentedLogo: String
    let presentedDisplayLogo: String
    let presentedLogoAlignment: String
    let presentedSearchLogo: String
    let presentedSearchLogoAlignment: String
}

// MARK: - Media Type

struct Media {
    let id: String?
    let type: String
    let title: String
    let slug: String
    let createdAt: String
    let rating: Float
    let description: String
    let cast: String
    let writers: String
    let duration: String
    let length: String
    let genres: [String]
    let hasWatched: Bool
    let isHD: Bool
    let isExclusive: Bool
    let isNewRelease: Bool
    let isSecret: Bool
    let resources: MediaResources
    let seasons: [String]?
    let timesSearched: Int
}

// MARK: - Mediable Implementation

extension Media: Mediable {}

// MARK: - Equatable Implementation

extension Media: Equatable {
    static func ==(lhs: Media, rhs: Media) -> Bool { lhs.id == rhs.id }
}

// MARK: - Hashable Implementation

extension Media: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - MediaType Type

extension Media {
    enum MediaType: String {
        case none = ""
        case series
        case film
    }
}

// MARK: - Mapping

extension Media {
    func toDTO() -> MediaDTO {
        return .init(id: id,
                     type: type,
                     title: title,
                     slug: slug,
                     createdAt: createdAt,
                     rating: rating,
                     description: description,
                     cast: cast,
                     writers: writers,
                     duration: duration,
                     length: length,
                     genres: genres,
                     hasWatched: hasWatched,
                     isHD: isHD,
                     isExclusive: isExclusive,
                     isNewRelease: isNewRelease,
                     isSecret: isSecret,
                     resources: resources.toDTO(),
                     seasons: seasons,
                     timesSearched: timesSearched)
    }
}

extension MediaResources {
    func toDTO() -> MediaResourcesDTO {
        return .init(posters: posters,
                     logos: logos,
                     trailers: trailers,
                     displayPoster: displayPoster,
                     previewPoster: previewPoster,
                     previewUrl: previewUrl,
                     presentedPoster: presentedPoster,
                     presentedLogo: presentedLogo,
                     presentedDisplayLogo: presentedDisplayLogo,
                     presentedLogoAlignment: presentedLogoAlignment,
                     presentedSearchLogo: presentedSearchLogo,
                     presentedSearchLogoAlignment: presentedSearchLogoAlignment)
    }
}

extension Array where Element == Media {
    func toDTO() -> [MediaDTO] {
        return map { $0.toDTO() }
    }
}

// MARK: - Vacant Value

extension Media {
    static var vacantValue: Media {
        let resources = MediaResources(
            posters: [],
            logos: [],
            trailers: [],
            displayPoster: .toBlank(),
            previewPoster: .toBlank(),
            previewUrl: .toBlank(),
            presentedPoster: .toBlank(),
            presentedLogo: .toBlank(),
            presentedDisplayLogo: .toBlank(),
            presentedLogoAlignment: .toBlank(),
            presentedSearchLogo: .toBlank(),
            presentedSearchLogoAlignment: .toBlank())
        return Media(
            id: .toBlank(),
            type: .toBlank(),
            title: .toBlank(),
            slug: .toBlank(),
            createdAt: .toBlank(),
            rating: .zero,
            description: .toBlank(),
            cast: .toBlank(),
            writers: .toBlank(),
            duration: .toBlank(),
            length: .toBlank(),
            genres: [],
            hasWatched: false,
            isHD: false,
            isExclusive: false,
            isNewRelease: false,
            isSecret: false,
            resources: resources,
            seasons: [],
            timesSearched: .zero)
    }
}

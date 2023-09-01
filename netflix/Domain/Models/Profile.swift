//
//  Profile.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - Profile Type

struct Profile {
    enum MaturityRating: String {
        case none = "none"
        case pg13 = "pg-13"
        case r5 = "r-5"
    }
    
    enum DisplayLanguage: String {
        case english = "en"
    }
    
    enum AudioSubtitles: String {
        case english = "en"
    }
    
    struct Settings {
        let _id: String
        var maturityRating: MaturityRating
        var displayLanguage: DisplayLanguage
        var audioAndSubtitles: AudioSubtitles
        var autoplayNextEpisode: Bool
        var autoplayPreviews: Bool
        let profile: String
    }
    
    var _id: String?
    var name: String
    var image: String
    var active: Bool?
    var user: String?
    var settings: Settings?
}

// MARK: - Equatable Implementation

extension Profile: Equatable {
    static func ==(lhs: Profile, rhs: Profile) -> Bool {
        return lhs._id == rhs._id &&
            lhs.name == rhs.name &&
            lhs.image == rhs.image &&
            lhs.settings == rhs.settings
    }
}

extension Profile.Settings: Equatable {
    static func ==(lhs: Profile.Settings, rhs: Profile.Settings) -> Bool {
        return lhs.maturityRating == rhs.maturityRating &&
            lhs.displayLanguage == rhs.displayLanguage &&
            lhs.audioAndSubtitles == rhs.audioAndSubtitles &&
            lhs.autoplayNextEpisode == rhs.autoplayNextEpisode &&
            lhs.autoplayPreviews == rhs.autoplayPreviews
    }
}

// MARK: - Default Value

extension Profile.Settings {
    static var defaultValue: Profile.Settings {
        return .init(_id: .toBlank(),
                     maturityRating: .none,
                     displayLanguage: .english,
                     audioAndSubtitles: .english,
                     autoplayNextEpisode: true,
                     autoplayPreviews: true,
                     profile: .toBlank())
    }
}

// MARK: - Mapping

extension Profile {
    func toDTO() -> ProfileDTO {
        return ProfileDTO(_id: _id,
                          name: name,
                          image: image,
                          active: active ?? false,
                          user: user ?? .toBlank(),
                          settings: settings?.toDTO() ?? .defaultValue)
    }
}

extension Array where Element == Profile {
    func toDTO() -> [ProfileDTO] {
        return map { $0.toDTO() }
    }
}

extension Profile.Settings {
    func toDTO() -> ProfileDTO.Settings {
        return .init(_id: _id,
                     maturityRating: maturityRating.toDTO(),
                     displayLanguage: displayLanguage.toDTO(),
                     audioAndSubtitles: audioAndSubtitles.toDTO(),
                     autoplayNextEpisode: autoplayNextEpisode,
                     autoplayPreviews: autoplayPreviews,
                     profile: profile)
    }
}

extension Profile.MaturityRating {
    func toDTO() -> ProfileDTO.MaturityRating {
        return .init(rawValue: self.rawValue) ?? .none
    }
}

extension Profile.DisplayLanguage {
    func toDTO() -> ProfileDTO.DisplayLanguage {
        return .init(rawValue: self.rawValue) ?? .english
    }
}

extension Profile.AudioSubtitles {
    func toDTO() -> ProfileDTO.AudioSubtitles {
        return .init(rawValue: self.rawValue) ?? .english
    }
}

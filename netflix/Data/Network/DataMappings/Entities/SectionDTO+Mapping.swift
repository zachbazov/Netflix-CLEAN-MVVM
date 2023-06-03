//
//  SectionDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - SectionDTO Type

@objc
public final class SectionDTO: NSObject, Codable, NSSecureCoding {
    let id: Int
    let title: String
    var media: [MediaDTO]
    
    init(id: Int, title: String, media: [MediaDTO]) {
        self.id = id
        self.title = title
        self.media = media
    }
    
    // MARK: NSSecureCoding
    
    public static var supportsSecureCoding: Bool { true }
    
    public init?(coder: NSCoder) {
        self.id = coder.decodeInteger(forKey: "id")
        self.title = coder.decodeObject(of: NSString.self, forKey: "title") as? String ?? ""
        self.media = coder.decodeObject(of: [NSArray.self, MediaDTO.self], forKey: "media") as? [MediaDTO] ?? []
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(title, forKey: "title")
        coder.encode(media, forKey: "media")
    }
}

// MARK: - Mapping

extension SectionDTO {
    func toDomain() -> Section {
        return .init(id: id,
                     title: title,
                     media: media.map { $0.toDomain() })
    }
}

extension Array where Element == SectionDTO {
    func toDomain() -> [Section] {
        return map { $0.toDomain() }
    }
}

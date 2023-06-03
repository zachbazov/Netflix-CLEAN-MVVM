//
//  ProfileDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - ProfileDTO Type

@objc
public final class ProfileDTO: NSObject, Codable, NSSecureCoding {
    var _id: String? = nil
    let name: String
    let image: String
    var active: Bool
    let user: String
    
    init(_id: String? = nil, name: String, image: String, active: Bool, user: String) {
        self._id = _id
        self.name = name
        self.image = image
        self.active = active
        self.user = user
    }
    
    // MARK: NSSecureCoding Implementation
    
    public static var supportsSecureCoding: Bool { true }
    
    public func encode(with coder: NSCoder) {
        coder.encode(_id, forKey: "_id")
        coder.encode(name, forKey: "name")
        coder.encode(image, forKey: "image")
        coder.encode(active, forKey: "active")
        coder.encode(user, forKey: "user")
    }
    
    public required init?(coder: NSCoder) {
        self._id = coder.decodeObject(of: [ProfileDTO.self, NSString.self], forKey: "_id") as? String ?? ""
        self.name = coder.decodeObject(of: [ProfileDTO.self, NSString.self], forKey: "name") as? String ?? ""
        self.image = coder.decodeObject(of: [ProfileDTO.self, NSString.self], forKey: "image") as? String ?? ""
        self.active = coder.decodeBool(forKey: "active")
        self.user = coder.decodeObject(of: [ProfileDTO.self, NSString.self], forKey: "user") as? String ?? ""
    }
}

// MARK: - Mapping

extension ProfileDTO {
    func toDomain() -> Profile {
        guard let id = _id else {
            return .init(name: name, image: image, active: active, user: user)
        }
        return .init(_id: id, name: name, image: image, active: active, user: user)
    }
}

extension Array where Element == ProfileDTO {
    func toDomain() -> [Profile] {
        return map { $0.toDomain() }
    }
}

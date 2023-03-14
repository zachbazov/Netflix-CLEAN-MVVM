//
//  UserProfileDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - UserProfileDTO Type

@objc
public final class UserProfileDTO: NSObject, Codable, NSSecureCoding {
    let _id: String
    let name: String
    let image: String
    var active: Bool
    let user: String
    
    init(_id: String, name: String, image: String, active: Bool, user: String) {
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
        self._id = coder.decodeObject(of: [UserProfileDTO.self, NSString.self], forKey: "_id") as? String ?? ""
        self.name = coder.decodeObject(of: [UserProfileDTO.self, NSString.self], forKey: "name") as? String ?? ""
        self.image = coder.decodeObject(of: [UserProfileDTO.self, NSString.self], forKey: "image") as? String ?? ""
        self.active = coder.decodeBool(forKey: "active")
        self.user = coder.decodeObject(of: [UserProfileDTO.self, NSString.self], forKey: "user") as? String ?? ""
    }
}

// MARK: - Mapping

extension UserProfileDTO {
    func toDomain() -> UserProfile {
        return .init(_id: _id, name: name, image: image, active: active, user: user)
    }
}

extension Array where Element == UserProfileDTO {
    func toDomain() -> [UserProfile] {
        return map { $0.toDomain() }
    }
}

//
//  UserDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import CoreData

// MARK: - UserDTO Type

@objc
public final class UserDTO: NSObject, Codable, NSSecureCoding {
    var _id: String?
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirm: String?
    var role: String?
    var active: Bool?
    var token: String?
    var mylist: [String]?
    var profiles: [String]?
    
    init(_id: String? = nil,
         name: String? = nil,
         email: String? = nil,
         password: String? = nil,
         passwordConfirm: String? = nil,
         role: String? = nil,
         active: Bool? = nil,
         token: String? = nil,
         mylist: [String]? = [],
         profiles: [String]? = []) {
        self._id = _id
        self.name = name
        self.email = email
        self.password = password
        self.passwordConfirm = passwordConfirm
        self.role = role
        self.active = active
        self.token = token
        self.mylist = mylist
        self.profiles = profiles
    }
    
    // MARK: NSSecureCoding Implementation
    
    public static var supportsSecureCoding: Bool { true }
    
    public func encode(with coder: NSCoder) {
        coder.encode(_id, forKey: "_id")
        coder.encode(name, forKey: "name")
        coder.encode(email, forKey: "email")
        coder.encode(password, forKey: "password")
        coder.encode(passwordConfirm, forKey: "passwordConfirm")
        coder.encode(role, forKey: "role")
        coder.encode(active, forKey: "active")
        coder.encode(token, forKey: "token")
        coder.encode(mylist, forKey: "mylist")
        coder.encode(profiles, forKey: "profiles")
    }
    
    public required init?(coder: NSCoder) {
        self._id = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "_id") as? String
        self.name = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "name") as? String
        self.email = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "email") as? String
        self.password = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "password") as? String
        self.passwordConfirm = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "passwordConfirm") as? String
        self.role = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "role") as? String
        self.active = coder.decodeObject(of: [UserDTO.self, NSNumber.self], forKey: "active") as? Bool
        self.token = coder.decodeObject(of: [UserDTO.self, NSString.self], forKey: "token") as? String
        self.mylist = coder.decodeObject(of: [UserDTO.self, NSArray.self, NSString.self], forKey: "mylist") as? [String]
        self.profiles = coder.decodeObject(of: [UserDTO.self, NSArray.self, NSString.self], forKey: "profiles") as? [String]
    }
}

// MARK: - Mapping

extension UserDTO {
    func toDomain() -> User {
        return .init(_id: _id,
                     name: name,
                     email: email,
                     password: password,
                     passwordConfirm: passwordConfirm,
                     role: role,
                     active: active,
                     token: token,
                     mylist: mylist,
                     profiles: profiles)
    }
}

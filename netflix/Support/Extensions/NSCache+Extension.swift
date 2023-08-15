//
//  NSCache+Extension.swift
//  netflix
//
//  Created by Developer on 13/06/2023.
//

import UIKit

// MARK: - Caching Methods

extension NSCache where KeyType == NSString, ObjectType == UIImage {
    func set(_ image: UIImage, forKey identifier: NSString) {
        setObject(image, forKey: identifier)
    }
    
    func remove(for identifier: NSString) {
        removeObject(forKey: identifier)
    }
    
    func object(for identifier: NSString) -> UIImage? {
        return object(forKey: identifier)
    }
}

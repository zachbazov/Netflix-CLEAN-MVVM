//
//  ValueTransformer.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - ValueTransformerValue Type

private enum ValueTransformerValue: String {
    case user = "UserTransformer"
    case media = "MediaTransformer"
    case mediaResources = "MediaResourcesTransformer"
    case section = "SectionTransformer"
}

// MARK: - NSValueTransformerName Extension

extension NSValueTransformerName {
    static let userTransformer = NSValueTransformerName(rawValue: ValueTransformerValue.user.rawValue)
    static let mediaTransformer = NSValueTransformerName(rawValue: ValueTransformerValue.media.rawValue)
    static let mediaResourcesTransformer = NSValueTransformerName(rawValue: ValueTransformerValue.mediaResources.rawValue)
    static let sectionTransformer = NSValueTransformerName(rawValue: ValueTransformerValue.section.rawValue)
}

// MARK: - ValueTransformer Type

final class ValueTransformer<T: NSObject>: NSSecureUnarchiveFromDataTransformer {
    override class func allowsReverseTransformation() -> Bool { true }
    override class func transformedValueClass() -> AnyClass { T.self }
    override class var allowedTopLevelClasses: [AnyClass] { [NSArray.self, T.self] }
    
    // MARK: NSSecureUnarchiveFromDataTransformer Lifecycle
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type, received \(type(of: value)).")
        }
        return super.transformedValue(data)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let single = value as? T else {
            guard let array = value as? [T] else {
                fatalError("Wrong data type, received \(type(of: value)).")
            }
            return super.reverseTransformedValue(array)
        }
        return super.reverseTransformedValue(single)
    }
}

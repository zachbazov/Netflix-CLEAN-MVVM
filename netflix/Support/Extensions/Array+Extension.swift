//
//  Array+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 18/10/2022.
//

import Foundation

// MARK: - Array Extension

extension Array where Element == Media {
    func slice(_ maxLength: Int) -> [Element] { Array(prefix(maxLength)) }
    func toObjectIDs() -> [String] { map { String($0.id!) } }
    func toSet() -> Set<Element> { Set(self) }
}

extension Array where Element == String {
    func toSet() -> Set<Element> { Set(self) }
}

extension Array {
    var lastIndex: Int {
        return self.count - 1
    }
}

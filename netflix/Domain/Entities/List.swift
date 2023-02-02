//
//  List.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - List Type

final class List<T> {
    
    let user: String
    var media: [T]
    
    init(user: String, media: [T]) {
        self.user = user
        self.media = media
    }
}

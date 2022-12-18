//
//  MediaPage.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

struct MediaPage: Equatable {
    let page: Int
    let totalPages: Int
    let media: [Media]
}

//
//  NewsTableViewCellViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

struct NewsTableViewCellViewModel {
    let media: MediaDTO
}

extension NewsTableViewCellViewModel: Equatable {
    static func ==(lhs: NewsTableViewCellViewModel, rhs: NewsTableViewCellViewModel) -> Bool {
        return lhs.media.slug == rhs.media.slug
    }
}

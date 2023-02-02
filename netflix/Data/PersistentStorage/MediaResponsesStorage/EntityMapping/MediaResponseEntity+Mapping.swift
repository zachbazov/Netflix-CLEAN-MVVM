//
//  MediaResponseEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - MediaResponseEntity + Mapping

extension MediaResponseEntity {
    func toDTO() -> MediaHTTPDTO.Response {
        return .init(status: status!,
                     results: Int(results),
                     data: data!)
    }
}

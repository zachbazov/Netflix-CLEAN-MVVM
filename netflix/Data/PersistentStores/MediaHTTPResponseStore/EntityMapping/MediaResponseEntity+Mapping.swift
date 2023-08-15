//
//  MediaHTTPResponseEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - MediaHTTPResponseEntity + Mapping

extension MediaHTTPResponseEntity {
    func toDTO() -> MediaHTTPDTO.Response {
        return .init(status: status!,
                     results: Int(results),
                     data: data ?? [])
    }
}

//
//  SectionHTTPResponseEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 22/03/2023.
//

import Foundation

// MARK: - Mappings

extension SectionHTTPResponseEntity {
    func toDTO() -> SectionHTTPDTO.Response {
        return .init(status: status!, results: Int(results), data: data!)
    }
}

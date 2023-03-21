//
//  UserHTTPResponseEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - UserHTTPResponseEntity + Mapping

extension UserHTTPResponseEntity {
    func toDTO() -> UserHTTPDTO.Response? {
        guard let token = token else { return nil }
        return .init(status: status,
                     token: token,
                     data: data,
                     request: request?.toDTO())
    }
}

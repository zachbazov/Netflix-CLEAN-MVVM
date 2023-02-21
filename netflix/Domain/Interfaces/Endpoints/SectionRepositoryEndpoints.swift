//
//  SectionRepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - SectionsRepositoryEndpoints Type

protocol SectionsRepositoryEndpoints {
    static func getAllSections() -> Endpoint<SectionHTTPDTO.Response>
}

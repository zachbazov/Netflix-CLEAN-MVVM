//
//  ImageDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 07/02/2023.
//

import Foundation

// MARK: - DataURIDTO Type

struct DataURIDTO: Codable {
    let type: String
    let data: [UInt8]
}

// MARK: - ImageOutputDTO Type

struct ImageOutputDTO: Codable {
    let dataUri: DataURIDTO
}

// MARK: - ImageDTO Type

struct ImageDTO: Codable {
    let name: String
    let path: String
    let type: String
    let output: ImageOutputDTO
}

// MARK: - Mapping

extension DataURIDTO {
    func toDomain() -> DataURI {
        return .init(type: type, data: data)
    }
}

extension ImageOutputDTO {
    func toDomain() -> ImageOutput {
        return .init(dataUri: dataUri.toDomain())
    }
}

extension ImageDTO {
    func toDomain() -> Image {
        return .init(name: name,
                     path: path,
                     type: type,
                     output: output.toDomain())
    }
}

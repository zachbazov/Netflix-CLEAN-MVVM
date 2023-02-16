//
//  ImageHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 07/02/2023.
//

import Foundation

// MARK: - ImageHTTPDTO Type

struct ImageHTTPDTO: HTTP {
    struct Request: Decodable {
        let name: String
        var type: String?
    }
    
    struct Response: Codable {
        let status: String
        let results: Int
        let data: [ImageDTO]
    }
}

// MARK: - Methods

extension ImageHTTPDTO.Response {
    func base64() -> Data? {
        guard !data.isEmpty,
              let bytes = data.first!.output.dataUri.data as [UInt8]?,
              let imageData = Data(bytes: bytes, count: bytes.count) as Data?,
              let base64Data = Data(base64Encoded: imageData) else {
            return nil
        }
        return base64Data
    }
}

// MARK: - Mapping

extension ImageHTTPDTO.Request {
    func toDomain() -> ImageHTTP.Request {
        return .init(name: name, type: type ?? nil)
    }
}

extension ImageHTTPDTO.Response {
    func toDomain() -> ImageHTTP.Response {
        return .init(status: status,
                     results: results,
                     data: data.map { $0.toDomain() })
    }
}

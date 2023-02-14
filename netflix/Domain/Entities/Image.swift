//
//  Image.swift
//  netflix
//
//  Created by Zach Bazov on 07/02/2023.
//

import Foundation

// MARK: - DataURI Type

struct DataURI {
    let type: String
    let data: [UInt8]
}

// MARK: - ImageOutput Type

struct ImageOutput {
    let dataUri: DataURI
}

// MARK: - Image Type

struct Image {
    let name: String
    let path: String
    let type: String
    let output: ImageOutput
}

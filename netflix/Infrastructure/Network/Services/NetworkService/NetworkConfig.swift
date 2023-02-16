//
//  NetworkConfig.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - NetworkConfigurable Protocol

protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

// MARK: - NetworkConfig Type

struct NetworkConfig: NetworkConfigurable {
    let baseURL: URL
    let headers: [String: String] = [:]
    let queryParameters: [String: String] = [:]
}

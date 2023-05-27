//
//  APIConfigurable.swift
//  netflix
//
//  Created by Zach Bazov on 19/02/2023.
//

import Foundation

// MARK: - APIConfigurable Type

protocol APIConfigurable {
    var apiScheme: String { get }
    var apiHost: String { get }
}

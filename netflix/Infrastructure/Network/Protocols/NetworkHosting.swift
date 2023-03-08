//
//  NetworkHosting.swift
//  netflix
//
//  Created by Zach Bazov on 19/02/2023.
//

import Foundation

// MARK: - NetworkHosting Type

protocol NetworkHosting {
    var apiScheme: String { get }
    var apiHost: String { get }
}

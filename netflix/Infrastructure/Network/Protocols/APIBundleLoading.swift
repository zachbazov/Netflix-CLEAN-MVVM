//
//  APIBundleLoading.swift
//  netflix
//
//  Created by Zach Bazov on 19/02/2023.
//

import Foundation

protocol APIBundleLoading {
    var apiScheme: String { get }
    var apiHost: String { get }
}

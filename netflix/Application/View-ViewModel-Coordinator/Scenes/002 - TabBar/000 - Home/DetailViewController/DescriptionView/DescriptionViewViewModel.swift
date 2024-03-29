//
//  DescriptionViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var description: String { get }
    var cast: String { get }
    var writers: String { get }
}

// MARK: - DescriptionViewViewModel Type

struct DescriptionViewViewModel {
    let description: String
    let cast: String
    let writers: String
    
    /// Create a description view view model object.
    /// - Parameter media: Corresponding media object.
    init(with media: Media?) {
        guard let media = media else { fatalError() }
        
        self.description = media.description
        self.cast = media.cast
        self.writers = media.writers
    }
}

// MARK: - ViewModel Implementation

extension DescriptionViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DescriptionViewViewModel: ViewModelProtocol {}

//
//  TrailerCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - TrailerCollectionViewCell Type

final class TrailerCollectionViewCell: DetailCollectionViewCell {
    
    // MARK: ViewLifecycleBehavior Implementation
    
    override func viewDidLoad() {
        super.dataWillLoad()
        
        viewWillConfigure()
    }
    
    override func viewWillConfigure() {
        super.viewWillConfigure()
        
        setTitle(viewModel.title)
    }
}

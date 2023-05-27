//
//  NewsNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - NewsNavigationView Type

final class NewsNavigationView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var airPlayButton: UIButton!
    @IBOutlet private weak var accountButton: UIButton!
    
    init() {
        super.init(frame: .zero)
        
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewInstantiable Implementation

extension NewsNavigationView: ViewInstantiable {}

//
//  DownloadsNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - DownloadsNavigationView Type

final class DownloadsNavigationView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var airPlayButton: UIButton!
    @IBOutlet private var accountButton: UIButton!
    
    init() {
        super.init(frame: .zero)
        
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewInstantiable Implementation

extension DownloadsNavigationView: ViewInstantiable {}

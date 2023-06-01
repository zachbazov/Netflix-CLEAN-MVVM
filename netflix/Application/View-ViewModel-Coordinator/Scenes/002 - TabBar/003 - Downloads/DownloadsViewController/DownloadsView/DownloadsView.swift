//
//  DownloadsView.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - DownloadsView Type

final class DownloadsView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var infoTextView: UITextView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var setupButton: UIButton!
    @IBOutlet private var canDownloadButton: UIButton!
    
    init() {
        super.init(frame: .zero)
        
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension DownloadsView: ViewInstantiable {}

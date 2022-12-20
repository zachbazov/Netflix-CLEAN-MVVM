//
//  DownloadsView.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

final class DownloadsView: UIView, ViewInstantiable {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var infoTextView: UITextView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var setupButton: UIButton!
    @IBOutlet private var canDownloadButton: UIButton!
    
    init(on parent: UIView) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

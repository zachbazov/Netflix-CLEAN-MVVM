//
//  DownloadsNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

final class DownloadsNavigationView: UIView, ViewInstantiable {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var airPlayButton: UIButton!
    @IBOutlet private var accountButton: UIButton!
    
    init(on parent: UIView) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
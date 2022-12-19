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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

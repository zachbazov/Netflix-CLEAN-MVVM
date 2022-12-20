//
//  NewsNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

final class NewsNavigationView: UIView, ViewInstantiable {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var airPlayButton: UIButton!
    @IBOutlet private weak var accountButton: UIButton!
    
    init(on parent: UIView) {
        super.init(frame: parent.bounds)
        parent.addSubview(self)
        self.nibDidLoad()
        self.constraintToSuperview(parent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

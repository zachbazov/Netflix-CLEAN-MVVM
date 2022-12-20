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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

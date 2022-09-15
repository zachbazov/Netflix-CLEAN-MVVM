//
//  PanelView.swift
//  netflix
//
//  Created by Zach Bazov on 10/09/2022.
//

import UIKit

// MARK: - PanelView class

final class PanelView: UIView, ViewInstantiable {
    
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var leadingPanelItemView: DefaultPanelItemView!
    @IBOutlet private weak var trailingPanelItemView: DefaultPanelItemView!
    
    private var viewModel: DefaultHomeViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nibDidLoad()
        self.setupViews()
    }
    
    deinit {
        viewModel = nil
    }
    
    private func setupViews() {
        
    }
}

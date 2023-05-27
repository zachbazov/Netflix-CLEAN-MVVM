//
//  DetailTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 25/05/2023.
//

import UIKit

// MARK: - DetailTableViewCell Type

class DetailTableViewCell: TableViewCell<DetailViewModel> {
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.black)
        selectionStyle = .none
    }
    
    override func viewWillDeallocate() {
        viewModel = nil
        
        removeFromSuperview()
    }
}

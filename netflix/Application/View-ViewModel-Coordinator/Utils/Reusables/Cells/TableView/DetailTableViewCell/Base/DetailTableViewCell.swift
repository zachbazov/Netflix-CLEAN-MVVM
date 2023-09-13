//
//  DetailTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 25/05/2023.
//

import UIKit

// MARK: - DetailTableViewCell Type

class DetailTableViewCell: UITableViewCell, TableViewCell {
    var viewModel: DetailViewModel!
    
    deinit {
        viewWillDeallocate()
    }
    
    // MARK: TableViewCell Implementation
    
    func viewDidLoad() {
        viewWillConfigure()
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.black)
        selectionStyle = .none
    }
    
    func viewWillDeallocate() {
        viewModel = nil
        
        removeFromSuperview()
    }
}

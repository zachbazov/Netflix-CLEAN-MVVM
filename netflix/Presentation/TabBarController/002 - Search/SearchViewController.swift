//
//  SearchViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import UIKit

final class SearchViewController: UIViewController {
    var viewModel: SearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .red
    }
}

//
//  MyNetflixNavigationTableHeaderView.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import UIKit

// MARK: - MyNetflixNavigationTableHeaderView Type

final class MyNetflixNavigationTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var airPlayButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var menuButton: UIButton!
    
    var viewModel: MyNetflixNavigationTableHeaderViewModel!
    
    var index: Int?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TableViewHeader Implementation

extension MyNetflixNavigationTableHeaderView: TableViewHeader {
    func viewDidLoad() {
        viewDidTargetSubviews()
        viewDidConfigure()
    }
    
    func viewDidTargetSubviews() {
        airPlayButton.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
    }
    
    func viewDidConfigure() {
        setTitle(viewModel.title)
    }
    
    func setTitle(_ string: String) {
        titleLabel.text = string
    }
}

// MARK: - ViewInstantiable Implementation

extension MyNetflixNavigationTableHeaderView: ViewInstantiable {}

// MARK: - Private Implementation

extension MyNetflixNavigationTableHeaderView {
    @objc
    private func didSelect(_ sender: UIButton) {
        let coordinator = viewModel.coordinator
        
        switch sender {
        case airPlayButton:
            airPlayButton.toRoutePickerView()
        case searchButton:
            coordinator.coordinate(to: .search)
        case menuButton:
            break
        default:
            break
        }
    }
}

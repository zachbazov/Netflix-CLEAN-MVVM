//
//  MyNetflixProfileTableViewCell.swift
//  netflix
//
//  Created by Developer on 10/09/2023.
//

import UIKit

// MARK: - MyNetflixProfileTableViewCell Type

final class MyNetflixProfileTableViewCell: UITableViewCell {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var labelContainer: UIView!
    @IBOutlet private weak var label: UILabel!
    
    var viewModel: MyNetflixProfileTableViewCellViewModel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.nibDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - TableViewCell Implementation

extension MyNetflixProfileTableViewCell: TableViewCell {
    func viewDidLoad() {
        viewDidConfigure()
        
        getSelectedProfile()
    }
    
    func viewDidConfigure() {
        button.imageView?.cornerRadius(10.0)
    }
}

// MARK: - Private Implementation

extension MyNetflixProfileTableViewCell {
    private func getSelectedProfile() {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel else { return }
        
        viewModel.getSelectedProfile { [weak self] response in
            guard let self = self, let response = response else { return }
            
            self.updateUI(for: response)
        }
    }
    
    private func setTitle(_ string: String) {
        label.text = string
    }
    
    private func setImage(_ string: String) {
        let image = UIImage(named: string)
        
        button.setImage(image, for: .normal)
    }
    
    private func updateUI(for response: ProfileHTTPDTO.GET.Response) {
        guard let profile = response.data.first?.toDomain() else { return }
        
        setTitle(profile.name)
        setImage(profile.image)
    }
}

//
//  PanelView.swift
//  netflix
//
//  Created by Zach Bazov on 10/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func playDidTap()
    func myListDidTap()
    func selectIfNeeded()
}

// MARK: - PanelView Type

final class PanelView: View<ShowcaseTableViewCellViewModel> {
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var myListButton: UIButton!
    
    /// Create a panel view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel) {
        super.init(frame: .zero)
        self.nibDidLoad()
        parent.addSubview(self)
        self.viewModel = viewModel
        self.constraintToSuperview(parent)
        self.viewDidConfigure()
        self.viewDidTargetSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewModel = nil
    }
    
    override func viewDidConfigure() {
        playButton.layer.cornerRadius = 6.0
        myListButton.layer.cornerRadius = 6.0
        
        selectIfNeeded()
    }
    
    override func viewDidTargetSubviews() {
        playButton.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
        myListButton.addTarget(self, action: #selector(myListDidTap), for: .touchUpInside)
    }
}

// MARK: - ViewInstantiable Implementation

extension PanelView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension PanelView: ViewProtocol {
    @objc
    fileprivate func playDidTap() {
        let coordinator = viewModel.coordinator!
        let section = viewModel.sectionAt(.resumable)
        let media = viewModel.presentedMedia!
        let rotated = true
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = rotated
        coordinator.coordinate(to: .detail)
    }
    
    @objc
    fileprivate func myListDidTap() {
        let media = viewModel.presentedMedia!
        viewModel.myList.viewModel.shouldAddOrRemove(media, uponSelection: myListButton.isSelected)
        viewModel.coordinator?.viewController?.browseOverlayView?.collectionView.reloadData()
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15.0)
        let plus = UIImage(systemName: "plus")!.whiteRendering(with: symbolConfiguration)
        let checkmark = UIImage(systemName: "checkmark")!.whiteRendering(with: symbolConfiguration)
        myListButton.setImage(plus, for: .normal)
        myListButton.setImage(checkmark, for: .selected)
        
        myListButton.isSelected = !myListButton.isSelected
    }
    
    fileprivate func selectIfNeeded() {
        guard let presentedMedia = viewModel.presentedMedia else { return }
        
        let myListViewModel = viewModel.myList.viewModel
        
        myListButton.isSelected = myListViewModel.contains(
            presentedMedia,
            in: viewModel.sectionAt(.myList).media)
    }
}

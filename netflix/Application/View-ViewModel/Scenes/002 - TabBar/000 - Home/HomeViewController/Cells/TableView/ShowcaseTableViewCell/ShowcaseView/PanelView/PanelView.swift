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
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel?) {
        super.init(frame: .zero)
        
        self.nibDidLoad()
        
        self.viewModel = viewModel
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.viewDidConfigure()
        self.viewDidTargetSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        viewModel = nil
    }
    
    override func viewDidConfigure() {
        configureButtons()
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
        guard let homeViewModel = viewModel?.coordinator?.viewController?.viewModel,
              let coordinator = viewModel?.coordinator
        else { return }
        
        let section = viewModel.sectionAt(.resumable)
        let media = viewModel.presentedMedia!
        let rotated = true
        
        homeViewModel.detailSection = section
        homeViewModel.detailMedia = media
        homeViewModel.shouldScreenRotate = rotated
        
        coordinator.coordinate(to: .detail)
    }
    
    @objc
    fileprivate func myListDidTap() {
        guard let media = viewModel?.presentedMedia,
              let myList = viewModel?.myList,
              let controller = viewModel?.coordinator?.viewController
        else { return }
        
        myList.viewModel.shouldAddOrRemove(media, uponSelection: myListButton.isSelected)
        
        controller.browseOverlayView?.reloadData()
        
        myListButton.toggle()
    }
    
    fileprivate func selectIfNeeded() {
        guard let presentedMedia = viewModel?.presentedMedia,
              let myList = viewModel?.myList
        else { return }
        
        let media = viewModel.sectionAt(.myList).media
        let contains = myList.viewModel.contains(presentedMedia, in: media)
        
        myListButton.toggle(contains)
    }
}

// MARK: - Private Presentation Logic

extension PanelView {
    private func configureButtons() {
        configurePlayButton()
        configureMyListButton()
    }
    
    private func configurePlayButton() {
        playButton.cornerRadius(6.0)
    }
    
    private func configureMyListButton() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15.0)
        let plus = UIImage(systemName: "plus")!.whiteRendering(with: symbolConfiguration)
        let checkmark = UIImage(systemName: "checkmark")!.whiteRendering(with: symbolConfiguration)
        myListButton.setImage(plus, for: .normal)
        myListButton.setImage(checkmark, for: .selected)
        myListButton.cornerRadius(6.0)
    }
}

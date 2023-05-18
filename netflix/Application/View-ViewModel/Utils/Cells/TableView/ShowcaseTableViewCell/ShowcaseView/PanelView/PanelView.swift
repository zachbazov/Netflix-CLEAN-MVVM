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

final class PanelView: View<PanelViewModel> {
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var myListButton: UIButton!
    
    private let parent: UIView
    private let myList = MyList.shared
    
    /// Create a panel view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel) {
        self.parent = parent
        
        super.init(frame: .zero)
        
        self.viewModel = PanelViewModel(with: viewModel)
        
        self.nibDidLoad()
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillTargetSubviews()
    }
    
    override func viewHierarchyWillConfigure() {
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
    }
    
    override func viewWillConfigure() {
        configurePlayButton()
        configureMyListButton()
        selectIfNeeded()
    }
    
    override func viewWillTargetSubviews() {
        playButton.addTarget(self, action: #selector(playDidTap), for: .touchUpInside)
        myListButton.addTarget(self, action: #selector(myListDidTap), for: .touchUpInside)
    }
    
    override func viewWillDeallocate() {
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension PanelView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension PanelView: ViewProtocol {
    @objc
    fileprivate func playDidTap() {
        let coordinator = viewModel.coordinator
        
        coordinator.coordinate(to: .detail)
        
        guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        let media = viewModel?.media
        let section = viewModel?.sectionAt(.resumable)
        
        controller.viewModel.media = media
        controller.viewModel.section = section
        controller.viewModel.isRotated = true
        controller.viewModel.orientation.orientation = true ? .landscapeLeft : .portrait
    }
    
    @objc
    fileprivate func myListDidTap() {
        guard let controller = viewModel?.coordinator.viewController,
              let showcase = viewModel?.media
        else { return }
        
        myList.viewModel.shouldAddOrRemove(showcase, uponSelection: myListButton.isSelected)
        
        controller.browseOverlayView?.reloadData()
        
        myListButton.toggle()
    }
    
    fileprivate func selectIfNeeded() {
        guard let showcase = viewModel?.media else { return }
        
        let media = viewModel.sectionAt(.myList).media
        let contains = myList.viewModel.contains(showcase, in: media)
        
        myListButton.toggle(contains)
    }
}

// MARK: - Private Presentation Logic

extension PanelView {
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

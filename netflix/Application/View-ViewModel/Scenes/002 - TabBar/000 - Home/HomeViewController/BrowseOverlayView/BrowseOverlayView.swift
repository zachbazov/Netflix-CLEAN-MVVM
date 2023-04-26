//
//  BrowseOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var collectionView: UICollectionView { get }
    var dataSource: BrowseOverlayCollectionViewDataSource? { get }
    
    func createCollectionView() -> UICollectionView
    func createDataSource() -> BrowseOverlayCollectionViewDataSource?
    func sectionDidChange(_ section: Section)
}

// MARK: - BrowseOverlayView Type

final class BrowseOverlayView: View<BrowseOverlayViewModel> {
    private(set) lazy var collectionView: UICollectionView = createCollectionView()
    private(set) lazy var dataSource: BrowseOverlayCollectionViewDataSource? = createDataSource()
    
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        
        self.viewModel = BrowseOverlayViewModel(with: viewModel)
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        viewDidUnbindObservers()
    }
    
    override func viewDidLoad() {
        viewDidBindObservers()
    }
    
    override func viewDidBindObservers() {
        viewModel?.isPresented.observe(on: self) { [weak self] _ in
            guard let self = self else { return }
            
            self.viewWillAnimateAppearance()
        }
        
        viewModel?.section.observe(on: self) { [weak self] section in
            guard let self = self else { return }
            
            self.sectionDidChange(section)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard viewModel.isNotNil else { return }
        
        viewModel?.isPresented.remove(observer: self)
        viewModel?.section.remove(observer: self)
        
        printIfDebug(.debug, "Removed \(Self.self) observers.")
    }
    
    override func viewWillAnimateAppearance() {
        guard let controller = viewModel?.coordinator.viewController else { return }
        
        if viewModel?.isPresented.value ?? false {
            controller.view.animateUsingSpring(
                withDuration: 0.5,
                withDamping: 1.0,
                initialSpringVelocity: 0.7,
                animations: {
                    controller.browseOverlayViewContainer.alpha = 1.0
                    controller.browseOverlayViewContainer.transform = .identity
                })
            
            return
        }
        
        controller.view.animateUsingSpring(
            withDuration: 0.5,
            withDamping: 1.0,
            initialSpringVelocity: 0.7,
            animations: {
                controller.browseOverlayViewContainer.alpha = .zero
                controller.browseOverlayViewContainer.transform = CGAffineTransform(translationX: .zero, y: controller.browseOverlayViewContainer.bounds.height)
            })
    }
    
    override func viewWillDeallocate() {
        viewDidUnbindObservers()
        
        collectionView.dataSource = nil
        collectionView.delegate = nil
        collectionView.removeFromSuperview()
        
        dataSource = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension BrowseOverlayView: ViewProtocol {
    fileprivate func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .navigationOverlay, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        
        collectionView.register(StandardCollectionViewCell.nib,
                                forCellWithReuseIdentifier: StandardCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .black
        
        addSubview(collectionView)
        
        return collectionView
    }
    
    fileprivate func createDataSource() -> BrowseOverlayCollectionViewDataSource? {
        guard let viewModel = viewModel?.coordinator.viewController?.viewModel else { return nil }
        
        let dataSource = BrowseOverlayCollectionViewDataSource(with: viewModel)
        
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        
        return dataSource
    }
    
    fileprivate func sectionDidChange(_ section: Section) {
        dataSource?.section = section
        
        collectionView.reloadData()
    }
}

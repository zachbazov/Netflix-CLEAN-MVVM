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
    
    func drawNavigationGradientIfNeeded(_ condition: Bool)
    func drawNavigationBlurIfNeeded(_ condition: Bool)
    func reloadData()
}

// MARK: - BrowseOverlayView Type

final class BrowseOverlayView: View<BrowseOverlayViewModel> {
    private(set) lazy var collectionView: UICollectionView = createCollectionView()
    private(set) lazy var dataSource: BrowseOverlayCollectionViewDataSource? = createDataSource()
    
    private let parent: UIView
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    init(on parent: UIView, with viewModel: HomeViewModel) {
        self.parent = parent
        
        super.init(frame: parent.bounds)
        
        self.viewModel = BrowseOverlayViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillBindObservers()
    }
    
    override func viewHierarchyWillConfigure() {
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
        
        collectionView.constraintToSuperview(parent)
    }
    
    override func viewWillBindObservers() {
        viewModel?.isPresented.observe(on: self) { [weak self] presented in
            guard let self = self else { return }
            
            self.viewShouldAppear(presented)
            
            self.drawNavigationGradientIfNeeded(presented)
            self.drawNavigationBlurIfNeeded(presented)
        }
        
        viewModel?.section.observe(on: self) { [weak self] _ in self?.reloadData() }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isPresented.remove(observer: self)
        viewModel.section.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillAnimateAppearance() {
        guard let controller = viewModel?.coordinator.viewController else { return }
        
        controller.view.animateUsingSpring(
            withDuration: 0.5,
            withDamping: 1.0,
            initialSpringVelocity: 0.7,
            animations: {
                controller.browseOverlayViewContainer.alpha = 1.0
                controller.browseOverlayViewContainer.transform = .identity
            })
    }
    
    override func viewWillAnimateDisappearance() {
        guard let controller = viewModel?.coordinator.viewController else { return }
        
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
        viewWillUnbindObservers()
        
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
        return BrowseOverlayCollectionViewDataSource(viewModel: viewModel)
    }
    
    fileprivate func drawNavigationGradientIfNeeded(_ condition: Bool) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        guard condition else {
            navigation.apply(.gradient)
            
            return
        }
        
        navigation.removeGradient()
    }
    
    fileprivate func drawNavigationBlurIfNeeded(_ condition: Bool) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        guard controller.dataSource!.primaryOffsetY == .zero else {
            guard condition else {
                navigation.setBackgroundColor(.clear)
                navigation.apply(.blur)
                
                return
            }
            
            navigation.removeBlur()
            navigation.setBackgroundColor(.black)
            
            return
        }
        
        drawNavigationGradientIfNeeded(condition)
    }
    
    func reloadData() {
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        
        collectionView.reloadData()
    }
}

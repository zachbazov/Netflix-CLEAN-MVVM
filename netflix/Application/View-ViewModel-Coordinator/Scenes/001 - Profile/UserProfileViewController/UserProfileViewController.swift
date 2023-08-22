//
//  UserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - UserProfileViewController Type

final class UserProfileViewController: UIViewController, Controller {
    fileprivate(set) lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate(set) lazy var dataSource: ProfileCollectionViewDataSource = createDataSource()
    
    var viewModel: ProfileViewModel!
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadBehaviors()
        viewHierarchyDidConfigure()
        viewDidDeploySubviews()
        viewDidConfigure()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceWillLockOrientation(.portrait)
    }
    
    func viewHierarchyDidConfigure() {
        collectionView
            .addToHierarchy(on: view)
            .constraintCenterToSuperview(view, dividingHeightBy: 1.75)
    }
    
    func viewDidDeploySubviews() {
        createLeftBarButtonItem()
        createRightBarButtonItem()
    }
    
    func viewDidConfigure() {
        title = "Who's Watching?"
    }
    
    func viewWillDeallocate() {
        navigationItem.leftBarButtonItem?.customView?.removeFromSuperview()
        navigationItem.leftBarButtonItem?.customView = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.customView?.removeFromSuperview()
        navigationItem.rightBarButtonItem?.customView = nil
        navigationItem.rightBarButtonItem = nil
        
        collectionView.removeFromSuperview()
        dataSource.collectionView.removeFromSuperview()
        
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - ViewAnimatable Implementation

extension UserProfileViewController: ViewAnimatable {
    func viewDidAnimateAppearance() {
        guard let navigationController = navigationController else { return }

        navigationController.view.alpha = .zero
        navigationController.view.transform = CGAffineTransform(translationX: navigationController.view.bounds.width,
                                                                y: .zero)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                navigationController.view.transform = .identity
                navigationController.view.alpha = 1.0
            })
    }
}

// MARK: - ThemeUpdatable Implementation

extension UserProfileViewController: ThemeUpdatable {
    func updateWithTheme() {
        for case let cell as ThemeUpdatable in collectionView.visibleCells {
            cell.updateWithTheme()
        }
        
        view.backgroundColor = Theme.backgroundColor
        collectionView.backgroundColor = Theme.backgroundColor
        
        navigationItem.leftBarButtonItem?.image = .themeControlImage
        
        setNeedsStatusBarAppearanceUpdate()
        view.setNeedsDisplay()
        collectionView.setNeedsDisplay()
    }
}

// MARK: - Private Implementation

extension UserProfileViewController {
    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds,
                                              collectionViewLayout: createLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .black
        collectionView.register(ProfileCollectionViewCell.nib,
                                forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        return collectionView
    }
    
    private func createDataSource() -> ProfileCollectionViewDataSource {
        return ProfileCollectionViewDataSource(for: collectionView, with: viewModel)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.49),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.53))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .uniform(size: 64.0)
        section.interGroupSpacing = 32.0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .themeControlImage,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(themeControlDidTap))
    }
    
    private func createRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editDidTap))
    }
    
    @objc
    private func editDidTap() {
        guard let coordinator = viewModel?.coordinator else { return }
        coordinator.coordinate(to: .editProfile)
    }
    
    @objc
    private func themeControlDidTap() {
        guard let navigationController = self.navigationController else { return }
        
        let themeType: Theme.ThemeType = Theme.currentTheme == .dark ? .light : .dark
        
        Theme.switchTo(theme: themeType)
        Theme.applyAppearance(for: navigationController)
        
        updateWithTheme()
    }
}

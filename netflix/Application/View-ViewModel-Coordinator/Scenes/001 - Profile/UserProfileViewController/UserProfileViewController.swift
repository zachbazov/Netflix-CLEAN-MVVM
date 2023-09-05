//
//  UserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - UserProfileViewController Type

final class UserProfileViewController: UIViewController, Controller {
    private(set) var collectionView: UICollectionView?
    private(set) var dataSource: ProfileCollectionViewDataSource?
    
    var viewModel: ProfileViewModel!
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewHierarchyDidConfigure()
        viewDidTargetSubviews()
        viewDidConfigure()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceWillLockOrientation(.portrait)
    }
    
    func viewDidLoadBehaviors() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    func viewHierarchyDidConfigure() {
        collectionView?
            .addToHierarchy(on: view)
            .constraintCenterToSuperview(view)
    }
    
    func viewDidDeploySubviews() {
        createCollectionView()
        createDataSource()
        createLeftBarButtonItem()
        createRightBarButtonItem()
    }
    
    func viewDidTargetSubviews() {
        collectionView?.addTapGesture(self, action: #selector(backgroundDidTap))
    }
    
    func viewDidConfigure() {
        title = viewModel.isEditing ? "Manage Profiles" : "Who's Watching?"
    }
    
    func viewWillDeallocate() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        
        collectionView?.removeFromSuperview()
        dataSource?.collectionView.removeFromSuperview()
        
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
        guard let collectionView = self.collectionView else { return }
        
        for case let cell as ThemeUpdatable in collectionView.visibleCells {
            cell.updateWithTheme()
        }
        
        view.backgroundColor = Theme.backgroundColor
        collectionView.backgroundColor = Theme.backgroundColor
        
        navigationItem.leftBarButtonItem?.image = .themeControl
        
        setNeedsStatusBarAppearanceUpdate()
        view.setNeedsDisplay()
        collectionView.setNeedsDisplay()
    }
}

// MARK: - Private Implementation

extension UserProfileViewController {
    private func createCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: .init())
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.backgroundColor = Theme.backgroundColor
    }
    
    private func createDataSource() {
        guard let collectionView = self.collectionView else { fatalError() }
        
        dataSource = ProfileCollectionViewDataSource(for: collectionView, with: viewModel)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.49),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.53))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let numOfItemsPerRow = floor(1.0 / itemSize.widthDimension.dimension)
        let numOfProfiles = CGFloat(viewModel.profiles.count)
        
        var numOfRows = numOfProfiles / numOfItemsPerRow
        numOfRows = numOfRows == 0.5 ? 2.0 : numOfRows
        
        let horizontalInset: CGFloat = 64.0
        let verticalInset = ((view.bounds.height * 0.50) / numOfRows) / 2.0
        
        section.contentInsets = NSDirectionalEdgeInsets(top: verticalInset,
                                                        leading: horizontalInset,
                                                        bottom: verticalInset,
                                                        trailing: horizontalInset)
        section.interGroupSpacing = 32.0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .themeControl,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(themeControlDidTap))
    }
    
    private func createRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.isEditing ? "Done" : "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(editDidTap))
    }
    
    @objc
    func editDidTap() {
        viewModel.isEditing = !viewModel.isEditing
        
        viewDidConfigure()
        navigationItem.rightBarButtonItem = nil
        createRightBarButtonItem()
        
        guard let collectionView = self.collectionView else { return }
        
        for case let cell as ProfileCollectionViewCell in collectionView.visibleCells {
            if cell.representedIdentifier != "addProfile" {
                cell.editMode(viewModel.isEditing)
            }
        }
    }
    
    @objc
    private func themeControlDidTap() {
        guard let navigationController = self.navigationController else { return }
        
        let themeType: Theme.ThemeType = Theme.currentTheme == .dark ? .light : .dark
        
        Theme.switchTo(theme: themeType)
        Theme.applyAppearance(for: navigationController)
        
        updateWithTheme()
    }
    
    @objc
    func backgroundDidTap() {
        if viewModel.isDeleting {
            for case let cell as ProfileCollectionViewCell in collectionView?.visibleCells ?? [] where cell.viewModel.name != "Add Profile" {
                cell.badgeViewContainer.hidden(viewModel.isDeleting)
            }
            
            viewModel.isDeleting = false
        }
    }
}

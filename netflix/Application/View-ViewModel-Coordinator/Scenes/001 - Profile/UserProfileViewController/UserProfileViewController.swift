//
//  UserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    var collectionView: UICollectionView { get }
    var dataSource: ProfileCollectionViewDataSource { get }
    
    func present()
    
    func createCollectionView() -> UICollectionView
    func createLayout() -> UICollectionViewCompositionalLayout
    
    func editDidTap()
}

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
        viewDidDeploySubviews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceWillLockOrientation(.portrait)
    }
    
    func viewDidDeploySubviews() {
        title = "Who's Watching?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editDidTap))
        setupCollectionView()
    }
    
    func viewWillDeallocate() {
        collectionView.removeFromSuperview()
        dataSource.collectionView.removeFromSuperview()
        
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - ViewControllerProtocol Implementation

extension UserProfileViewController: ViewControllerProtocol {
    func present() {
        guard let navigationController = navigationController else { return }

        navigationController.view.alpha = .zero
        navigationController.view.transform = CGAffineTransform(translationX: navigationController.view.bounds.width, y: .zero)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                navigationController.view.transform = .identity
                navigationController.view.alpha = 1.0
            })
    }
    
    fileprivate func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .black
        collectionView.register(ProfileCollectionViewCell.nib,
                                forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        return collectionView
    }
    
    fileprivate func createDataSource() -> ProfileCollectionViewDataSource {
        return ProfileCollectionViewDataSource(for: collectionView, with: viewModel)
    }
    
    fileprivate func createLayout() -> UICollectionViewCompositionalLayout {
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
    
    @objc
    fileprivate func editDidTap() {
        guard let coordinator = viewModel?.coordinator else { return }
        coordinator.coordinate(to: .editProfile)
    }
}

// MARK: - Private UI Implementation

extension UserProfileViewController {
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: view.bounds.height / 1.75),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        ])
    }
}

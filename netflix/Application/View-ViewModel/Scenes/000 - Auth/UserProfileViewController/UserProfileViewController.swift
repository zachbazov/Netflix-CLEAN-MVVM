//
//  UserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerInput {
    
}

private protocol ViewControllerOutput {
    
//    func present()
//    func didSelect()
}

private typealias ViewControllerProtocol = ViewControllerInput & ViewControllerOutput

// MARK: - UserProfileViewController Type

final class UserProfileViewController: Controller<UserProfileViewModel> {
    
    private lazy var collectionView: UICollectionView = createCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.didLockDeviceOrientation(.portrait)
    }
    
    override func viewDidDeploySubviews() {
        title = "Who's Watching?"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .edit, target: self, action: #selector(editDidTap))
        setupCollectionView()
    }
    
    override func viewDidTargetSubviews() {
        
    }
    
    @objc
    func editDidTap() {
        let authService = Application.app.services.authentication
        let coordinator = Application.app.coordinator
        
        if #available(iOS 13, *) {
            Task {
                guard let user = authService.user else { return }
                let request = UserHTTPDTO.Request(user: user)
                let status = await authService.signOut(with: request)
                
                guard status else { return }
                
                mainQueueDispatch { coordinator.coordinate(to: .auth) }
            }
            
            return
        }
        
        authService.signOut()
        
        mainQueueDispatch { coordinator.coordinate(to: .auth) }
    }
}

// MARK: - ViewControllerProtocol Implementation

extension UserProfileViewController: ViewControllerProtocol {
//    func present() {
//        guard let navigationController = navigationController else { return }
//
//        navigationController.view.alpha = .zero
//        navigationController.view.transform = CGAffineTransform(translationX: navigationController.view.bounds.width, y: .zero)
//
//        UIView.animate(
//            withDuration: 0.25,
//            delay: 0,
//            options: .curveEaseInOut,
//            animations: {
//                navigationController.view.transform = .identity
//                navigationController.view.alpha = 1.0
//            }
//        )
//    }
//
//    func didSelect() {
//        guard let navigationController = navigationController else { return }
//
//        UIView.animate(
//            withDuration: 0.25,
//            delay: 0,
//            options: .curveEaseInOut,
//            animations: {
//                navigationController.view.transform = CGAffineTransform(translationX: navigationController.view.bounds.width, y: .zero)
//                navigationController.view.alpha = .zero
//            },
//            completion: { [weak self] _ in
//                self?.remove()
//                self?.viewModel?.coordinator?.userProfile = nil
//                self?.viewModel = nil
//            }
//        )
//    }
    
    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UserProfileCollectionViewCell.nib, forCellWithReuseIdentifier: UserProfileCollectionViewCell.reuseIdentifier)
        return collectionView
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
    
    func dataSourceDidChange() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
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

//

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.profiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UserProfileCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel)
    }
}







extension NSDirectionalEdgeInsets {
    static func uniform(size: CGFloat) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: size, leading: size, bottom: size, trailing: size)
    }
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    static func small() -> NSDirectionalEdgeInsets {
        return .uniform(size: 5)
    }
    static func medium() -> NSDirectionalEdgeInsets {
        return .uniform(size: 15)
    }
    static func large() -> NSDirectionalEdgeInsets {
        return .uniform(size: 30)
    }
}

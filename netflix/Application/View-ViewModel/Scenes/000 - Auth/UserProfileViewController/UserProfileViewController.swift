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
        setupCollectionView()
    }
    
    override func viewDidTargetSubviews() {
        
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
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: .init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }
}

// MARK: - Private UI Implementation

extension UserProfileViewController {
    private func setupCollectionView() {
        view.addSubview(collectionView)
    }
}

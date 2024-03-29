//
//  AccountViewController.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    func backButtonDidTap()
    func signOutDidTap()
}

// MARK: - AccountViewController Type

final class AccountViewController: UIViewController, Controller {
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var profileLabel: UILabel!
    @IBOutlet private weak var collectionContainer: UIView!
    @IBOutlet private weak var manageProfilesButton: UIButton!
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private weak var signOutButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    
    var viewModel: AccountViewModel!
    
    private(set) lazy var collectionView: UICollectionView = createCollectionView()
    private(set) lazy var profileDataSource: AccountProfileCollectionViewDataSource = createProfileDataSource()
//    private var accountMenuDataSource: AccountMenuTableViewDataSource?
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillLoadBehaviors()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillTargetSubviews()
        viewWillBindObservers()
        viewModel.viewDidLoad()
    }
    
    func viewWillDeploySubviews() {
        createAccountMenuDataSource()
    }
    
    func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: collectionContainer)
            .constraintToSuperview(collectionContainer)
    }
    
    func viewWillTargetSubviews() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutDidTap), for: .touchUpInside)
    }
    
    func viewWillBindObservers() {
        viewModel.profiles.observe(on: self) { [weak self] _ in
            guard let self = self else { return }
            
            self.profileDataSource.dataSourceDidChange()
        }
    }
    
    func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.profiles.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
//        accountMenuDataSource = nil
        
        collectionView.removeFromSuperview()
        
        viewModel?.coordinator = nil
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - ViewControllerProtocol Implementation

extension AccountViewController: ViewControllerProtocol {
    @objc
    fileprivate func backButtonDidTap() {
        viewWillAnimateDisappearance { [weak self] in
            self?.viewWillDeallocate()
        }
    }
    
    @objc
    func signOutDidTap() {
        signOut()
    }
}

// MARK: - Private Implementation

extension AccountViewController {
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .profile, scrollDirection: .horizontal)
        let collectionView = UICollectionView(frame: collectionContainer.bounds, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: .zero, left: 16.0, bottom: .zero, right: 16.0)
        collectionView.backgroundColor = .black
        return collectionView
    }
    
    private func createProfileDataSource() -> AccountProfileCollectionViewDataSource {
        return AccountProfileCollectionViewDataSource(with: viewModel)
    }
    
    private func createAccountMenuDataSource() {
//        accountMenuDataSource = AccountMenuTableViewDataSource(with: viewModel)
    }
    
    private func signOut() {
        let authService = Application.app.services.auth
        
        ActivityIndicatorView.present()
        
        authService.signOut() { [weak self] in
            self?.signOutDidComplete()
        }
    }
    
    private func signOutDidComplete() {
        ActivityIndicatorView.remove()
        
        backButtonDidTap()
        
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.viewWillDeallocate()

            let coordinator = Application.app.coordinator
            coordinator.deallocateTabBar()
            coordinator.coordinate(to: .auth)
        }
    }
}

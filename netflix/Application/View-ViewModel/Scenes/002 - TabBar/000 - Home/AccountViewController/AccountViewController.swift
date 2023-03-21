//
//  AccountViewController.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerOutput {
    func backButtonDidTap()
    func signOutDidTap()
    func signOut()
    func didFinish()
}

private typealias ViewControllerProtocol = ViewControllerOutput

// MARK: - AccountViewController Type

final class AccountViewController: Controller<AccountViewModel> {
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var profileLabel: UILabel!
    @IBOutlet private weak var collectionContainer: UIView!
    @IBOutlet private weak var manageProfilesButton: UIButton!
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private weak var signOutButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    
    private(set) lazy var collectionView: UICollectionView = createCollectionView()
    
    private(set) var profileDataSource: ProfileCollectionViewDataSource?
    private var accountMenuDataSource: AccountMenuTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewDidBindObservers()
        viewModel.viewDidLoad()
    }
    
    override func viewDidDeploySubviews() {
        setupCollectionView()
        setupTableView()
    }
    
    override func viewDidTargetSubviews() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutDidTap), for: .touchUpInside)
    }
    
    override func viewDidBindObservers() {
        viewModel.profiles.observe(on: self) { [weak self] _ in self?.profileDataSource?.dataSourceDidChange() }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        viewModel.profiles.remove(observer: self)
        printIfDebug(.debug, "Removed `AccountViewModel` observers.")
    }
    
    override func viewDidDeallocate() {
        viewDidUnbindObservers()
        
        profileDataSource = nil
        accountMenuDataSource = nil
        
        collectionView.removeFromSuperview()
        
        viewModel?.coordinator = nil
        viewModel = nil
        
        remove()
    }
}

// MARK: - ViewControllerProtocol Implementation

extension AccountViewController: ViewControllerProtocol {
    @objc
    fileprivate func backButtonDidTap() {
        super.viewWillAnimateDisappearance { [weak self] in self?.viewDidDeallocate() }
    }
    
    @objc
    func signOutDidTap() {
        signOut()
    }
    
    fileprivate func signOut() {
        let authService = Application.app.services.authentication
        let coordinator = Application.app.coordinator
        
        ActivityIndicatorView.viewDidShow()
        
        if #available(iOS 13, *) {
            Task {
                guard let user = authService.user else { return }
                
                let request = UserHTTPDTO.Request(user: user, selectedProfile: nil)
                let status = await authService.signOut(with: request)
                
                guard status else { return }
                
                ActivityIndicatorView.viewDidHide()
                
                backButtonDidTap()
                
                mainQueueDispatch { coordinator.coordinate(to: .auth) }
            }
            
            return
        }
        
        authService.signOut()
    }
    
    fileprivate func didFinish() {
        
    }
}

// MARK: - Private UI Implementation

extension AccountViewController {
    private func setupCollectionView() {
        collectionContainer.addSubview(collectionView)
        collectionView.constraintToSuperview(collectionContainer)
        
        profileDataSource = ProfileCollectionViewDataSource(with: viewModel)
    }
    
    private func setupTableView() {
        tableView.register(class: AccountMenuTableViewCell.self)
        
        accountMenuDataSource = AccountMenuTableViewDataSource(with: viewModel)
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .profile, scrollDirection: .horizontal)
        let collectionView = UICollectionView(frame: collectionContainer.bounds, collectionViewLayout: layout)
        collectionView.register(ProfileCollectionViewCell.nib, forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: .zero, left: 16.0, bottom: .zero, right: 16.0)
        collectionView.backgroundColor = .black
        return collectionView
    }
}

//
//  AccountViewController.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - AccountViewController Type

final class AccountViewController: Controller<AccountViewModel> {
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var profileLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
    }
    
    override func viewDidDeploySubviews() {
        
    }
    
    override func viewDidTargetSubviews() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    func present() {
        navigationController?.view.alpha = .zero
        navigationController?.view.transform = CGAffineTransform(translationX: navigationController!.view.bounds.width, y: .zero)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.navigationController?.view.transform = .identity
                self?.navigationController?.view.alpha = 1.0
            })
    }
    
    @objc
    fileprivate func backButtonDidTap() {
        guard let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as? HomeViewController else { return }
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.navigationController?.view.transform = CGAffineTransform(translationX: self!.navigationController!.view.bounds.width, y: .zero)
                self?.navigationController?.view.alpha = .zero
            },
            completion: { [weak self] _ in
                homeViewController.viewModel.coordinator?.account?.remove()
                self?.viewModel = nil
                homeViewController.viewModel.coordinator?.account = nil
            })
    }
    
    func signOut() {
//            let authService = Application.app.services.authentication
//            let coordinator = Application.app.coordinator
//
//            if #available(iOS 13, *) {
//                Task {
//                    guard let user = authService.user else { return }
//                    let request = UserHTTPDTO.Request(user: user)
//                    let status = await authService.signOut(with: request)
//
//                    guard status else { return }
//
//                    mainQueueDispatch { coordinator.coordinate(to: .auth) }
//                }
//
//                return
//            }
//
//            authService.signOut()
//
//            mainQueueDispatch { coordinator.coordinate(to: .auth) }
    }
}

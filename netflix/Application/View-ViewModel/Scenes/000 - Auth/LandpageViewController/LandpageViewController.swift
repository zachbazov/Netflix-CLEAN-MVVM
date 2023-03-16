//
//  LandpageViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerOutput {
    var signInBarButton: UIView! { get }
    var hasGradient: Bool { get }
    var hasAnimate: Bool { get }
}

private typealias ViewControllerProtocol = ViewControllerOutput

// MARK: - LandpageViewController Type

final class LandpageViewController: Controller<AuthViewModel> {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var statusBarGradientView: UIView!
    @IBOutlet private weak var topGradientView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var headlineTextView: UITextView!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    private weak var signInBarButton: UIView! {
        guard let rightBarButtonItemView = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView else {
            return nil
        }
        return rightBarButtonItemView
    }
    
    private var hasGradient = false
    private var hasAnimate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.didLockDeviceOrientation(.portrait)
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradients()
    }
    
    override func viewDidDeploySubviews() {
        setupNavigationBarButtonItem()
    }
    
    override func viewDidTargetSubviews() {
        signUpButton.addTarget(self, action: #selector(coordinateToSignUp), for: .touchUpInside)
    }
}

// MARK: - Private UI Implementation

extension LandpageViewController {
    private func setupNavigationBarButtonItem() {
        let string = Localization.Auth.Landpage().signInBarButton
        let button = UIBarButtonItem(title: string,
                                     style: .plain,
                                     target: self,
                                     action: #selector(coordinateToSignIn))
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupGradients() {
        guard !hasGradient else { return }
        hasGradient = true
        
        let locations: [NSNumber] = [0.0, 0.5, 1.0]
        statusBarGradientView.addGradientLayer(
            colors: [.black.withAlphaComponent(0.75),
                     .black.withAlphaComponent(0.5),
                     .clear],
            locations: locations)
        
        topGradientView.addGradientLayer(
            colors: [.clear,
                     .black.withAlphaComponent(0.5),
                     .black.withAlphaComponent(0.75)],
            locations: locations)
        
        bottomGradientView.addGradientLayer(
            colors: [.black.withAlphaComponent(0.75),
                     .black.withAlphaComponent(0.5),
                     .clear],
            locations: locations)
    }
    
    @objc
    private func coordinateToSignUp() {
        viewModel?.coordinator?.coordinate(to: .signUp)
    }
    
    @objc
    private func coordinateToSignIn() {
        viewModel?.coordinator?.coordinate(to: .signIn)
    }
    
    private func animateView() {
        guard !hasAnimate else { return }
        hasAnimate = true
        
        let offsetY: CGFloat = 64.0
        let scale: CGFloat = 1.2
        
        headlineTextView.alpha = .zero
        descriptionTextView.alpha = .zero
        statusBarGradientView.alpha = .zero
        topGradientView.alpha = .zero
        bottomGradientView.alpha = .zero
        signInBarButton.alpha = .zero
        backgroundImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        signUpButton.transform = CGAffineTransform(translationX: .zero, y: offsetY)
        headlineTextView.transform = CGAffineTransform(scaleX: scale, y: scale)
        navigationController?.navigationBar.transform = CGAffineTransform(translationX: .zero, y: -offsetY)
        
        UIView.animate(withDuration: 1.5, delay: 0.25, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundImageView.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.headlineTextView.alpha = 1.0
            
            self.topGradientView.alpha = 1.0
            self.bottomGradientView.alpha = 1.0
            
            self.signUpButton.transform = .identity
            
            self.navigationController?.navigationBar.transform = .identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                self.headlineTextView.transform = .identity
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.descriptionTextView.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.signInBarButton.alpha = 1.0
                }, completion: nil)
            })
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.75, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.statusBarGradientView.alpha = 1.0
        }, completion: nil)
    }
}

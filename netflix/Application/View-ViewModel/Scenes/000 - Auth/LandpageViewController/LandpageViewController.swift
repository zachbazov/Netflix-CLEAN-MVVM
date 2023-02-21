//
//  LandpageViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerOutput {
    var hasGradient: Bool { get }
}

private typealias ViewControllerProtocol = ViewControllerOutput

// MARK: - LandpageViewController Type

final class LandpageViewController: Controller<AuthViewModel> {
    @IBOutlet private weak var statusBarGradientView: UIView!
    @IBOutlet private weak var topGradientView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private weak var signUpButton: UIButton!
    
    private var hasGradient = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradients()
    }
    
    override func viewDidDeploySubviews() {
        setupNavigationBarButtonItem()
    }
    
    override func viewDidTargetSubviews() {
        signUpButton.addTarget(viewModel.coordinator,
                               action: #selector(viewModel.coordinator!.deploy(_:)),
                               for: .touchUpInside)
    }
}

// MARK: - Private UI Implementation

extension LandpageViewController {
    private func setupNavigationBarButtonItem() {
        let string = Localization.Auth.Landpage().signInBarButton
        let button = UIBarButtonItem(title: string,
                                     style: .plain,
                                     target: viewModel.coordinator,
                                     action: #selector(viewModel.coordinator!.deploy(_:)))
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupGradients() {
        if !hasGradient {
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
            
            hasGradient = true
        }
    }
}

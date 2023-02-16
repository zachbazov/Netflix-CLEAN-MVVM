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

final class LandpageViewController: ViewController {
    @IBOutlet private weak var statusBarGradientView: UIView!
    @IBOutlet private weak var topGradientView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private weak var signUpButton: UIButton!
    
    var viewModel: AuthViewModel!
    
    private var hasGradient = false
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidDeployBehaviors()
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradients()
    }
}

// MARK: - Private UI Implementation

extension LandpageViewController {
    private func setupSubviews() {
        setupNavigationBarButtonItem()
        setupTargets()
    }
    
    private func setupNavigationBarButtonItem() {
        let string = Localization.Auth.Landpage().signInBarButton
        let button = UIBarButtonItem(title: string,
                                     style: .plain,
                                     target: viewModel.coordinator,
                                     action: #selector(viewModel.coordinator!.deploy(_:)))
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupTargets() {
        signUpButton.addTarget(viewModel.coordinator,
                               action: #selector(viewModel.coordinator!.deploy(_:)),
                               for: .touchUpInside)
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

//
//  LandpageViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - LandpageViewController Type

final class LandpageViewController: UIViewController {
    
    // MARK: Outlet Properties
    
    @IBOutlet private weak var statusBarGradientView: UIView!
    @IBOutlet private weak var topGradientView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private weak var signUpButton: UIButton!
    
    // MARK: Type's Properties
    
    var viewModel: AuthViewModel!
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBehaviors()
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradientViews()
    }
}

// MARK: - UI Setup

extension LandpageViewController {
    private func setupBehaviors() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    private func setupSubviews() {
        setupNavigationBarButtonItem()
        setupTargets()
    }
    
    private func setupNavigationBarButtonItem() {
        let string = Localization.Auth.Landpage().signInBarButton
        let button = UIBarButtonItem(title: string,
                                     style: .plain,
                                     target: viewModel.coordinator,
                                     action: #selector(viewModel.coordinator!.present(_:)))
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupGradientViews() {
        statusBarGradientView.addGradientLayer(
            frame: statusBarGradientView.bounds,
            colors: [.black.withAlphaComponent(0.5),
                     .black.withAlphaComponent(0.25),
                     .clear],
            locations: [0.0, 0.5, 1.0])
        
        topGradientView.addGradientLayer(
            frame: topGradientView.bounds,
            colors: [.clear,
                     .black.withAlphaComponent(0.5),
                     .black.withAlphaComponent(0.75)],
            locations: [0.0, 0.5, 1.0])
        
        bottomGradientView.addGradientLayer(
            frame: bottomGradientView.bounds,
            colors: [.black.withAlphaComponent(0.75),
                     .black.withAlphaComponent(0.5),
                     .clear],
            locations: [0.0, 0.5, 1.0])
    }
    
    private func setupTargets() {
        signUpButton.addTarget(viewModel.coordinator,
                               action: #selector(viewModel.coordinator!.present(_:)),
                               for: .touchUpInside)
    }
}

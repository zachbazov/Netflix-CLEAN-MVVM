//
//  SignInViewController.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - SignInViewController Type

final class SignInViewController: UIViewController {
    
    // MARK: Outlet Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: Type's Properties
    
    var viewModel: SignInViewModel?
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup dark appearance.
        AppAppearance.dark()
        // Setup subviews.
        setupSubviews()
    }
}

// MARK: - UI Setup

extension SignInViewController {
    private func setupSubviews() {
        setAttributes(for: [emailTextField, passwordTextField])
        signInButton.setLayerBorder(.black, width: 1.5)
        setupTargets()
        addNavigationItemTitleView()
    }
    
    private func setupTargets() {
        signInButton.addTarget(viewModel, action: #selector(viewModel?.signInButtonDidTap), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
    }
}

// MARK: - Methods

extension SignInViewController {
    @objc
    func textFieldValueDidChange(_ textField: UITextField) {
        if emailTextField == textField { viewModel?.email = textField.text }
        else { viewModel?.password = textField.text }
    }
}

//
//  SignInViewController.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerInput {
    func textFieldValueDidChange(_ textField: UITextField)
}

private typealias ViewControllerProtocol = ViewControllerInput

// MARK: - SignInViewController Type

final class SignInViewController: Controller<SignInViewModel> {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
}

// MARK: - ViewControllerProtocol Implementation

extension SignInViewController: ViewControllerProtocol {
    @objc
    fileprivate func textFieldValueDidChange(_ textField: UITextField) {
        switch textField {
        case emailTextField: viewModel?.email = textField.text
        case passwordTextField: viewModel?.password = textField.text
        default: return
        }
    }
}

// MARK: - Private UI Implementation

extension SignInViewController {
    private func setupSubviews() {
        setAttributes(for: [emailTextField, passwordTextField])
        signInButton.setLayerBorder(.black, width: 1.5)
        setupTargets()
        viewDidBrandNavigationItemTitleView()
    }
    
    private func setupTargets() {
        signInButton.addTarget(viewModel, action: #selector(viewModel?.signInButtonDidTap), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
    }
}

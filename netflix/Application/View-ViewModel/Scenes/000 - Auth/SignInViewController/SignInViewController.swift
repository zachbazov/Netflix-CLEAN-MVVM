//
//  SignInViewController.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    func textFieldValueDidChange(_ textField: UITextField)
}

// MARK: - SignInViewController Type

final class SignInViewController: Controller<SignInViewModel> {
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewDidConfigure()
    }
    
    override func viewDidDeploySubviews() {
        setAttributes(for: [emailTextField, passwordTextField])
        
        signInButton.border(.black, width: 1.5)
        
        titleViewWillConfigure()
    }
    
    override func viewDidTargetSubviews() {
        signInButton.addTarget(viewModel, action: #selector(viewModel?.signInButtonDidTap), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
    }
    
    override func viewDidConfigure() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
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

// MARK: - UITextFieldDelegate Implementation

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

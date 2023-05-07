//
//  SignUpViewController.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    func textFieldValueDidChange(_ textField: UITextField)
}

// MARK: - SignUpViewController Type

final class SignUpViewController: Controller<SignUpViewModel> {
    @IBOutlet private(set) weak var nameTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var passwordConfirmTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewDidConfigure()
    }
    
    override func viewDidDeploySubviews() {
        setAttributes(for: [nameTextField, emailTextField,
                            passwordTextField, passwordConfirmTextField])
        
        signUpButton.border(.black, width: 1.5)
        
        titleViewWillConfigure()
    }
    
    override func viewDidTargetSubviews() {
        signUpButton.addTarget(viewModel, action: #selector(viewModel?.signUpButtonDidTap), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
    }
    
    override func viewDidConfigure() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
}

// MARK: - ViewControllerProtocol Implementation

extension SignUpViewController: ViewControllerProtocol {
    @objc
    fileprivate func textFieldValueDidChange(_ textField: UITextField) {
        switch textField {
        case nameTextField: viewModel?.name = textField.text
        case emailTextField: viewModel?.email = textField.text
        case passwordTextField: viewModel?.password = textField.text
        case passwordConfirmTextField: viewModel?.passwordConfirm = textField.text
        default: return
        }
    }
}

// MARK: - UITextFieldDelegate Implementation

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

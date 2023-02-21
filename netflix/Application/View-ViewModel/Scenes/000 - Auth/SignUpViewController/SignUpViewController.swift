//
//  SignUpViewController.swift
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

// MARK: - SignUpViewController Type

final class SignUpViewController: Controller<SignUpViewModel> {
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordConfirmTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidConfigure()
    }
    
    override func viewDidConfigure() {
        setAttributes(for: [nameTextField, emailTextField,
                            passwordTextField, passwordConfirmTextField])
        signUpButton.setLayerBorder(.black, width: 1.5)
        viewDidTargetSubviews()
        didConfigureTitleView()
    }
    
    override func viewDidTargetSubviews() {
        signUpButton.addTarget(viewModel, action: #selector(viewModel?.signUpButtonDidTap), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldValueDidChange), for: .editingChanged)
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

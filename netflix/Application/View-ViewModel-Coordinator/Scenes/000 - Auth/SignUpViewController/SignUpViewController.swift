//
//  SignUpViewController.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - SignUpViewController Type

final class SignUpViewController: UIViewController, Controller {
    @IBOutlet private(set) weak var nameTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var passwordConfirmTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    var viewModel: SignUpViewModel!
    
    deinit {
        viewDidDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewDidConfigure()
    }
    
    func viewDidDeploySubviews() {
        setAttributes(for: [nameTextField, emailTextField,
                            passwordTextField, passwordConfirmTextField])
        
        signUpButton.border(.black, width: 1.5)
        
        titleViewWillConfigure()
    }
    
    func viewDidTargetSubviews() {
        signUpButton.addTarget(viewModel, action: #selector(viewModel?.signUpButtonDidTap), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
    }
    
    func viewDidConfigure() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    func viewDidDeallocate() {
        viewModel?.coordinator = nil
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - TextFieldDelegate Implementation

extension SignUpViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc
    func valueDidChange(_ textField: UITextField) {
        switch textField {
        case nameTextField: viewModel?.name = textField.text
        case emailTextField: viewModel?.email = textField.text
        case passwordTextField: viewModel?.password = textField.text
        case passwordConfirmTextField: viewModel?.passwordConfirm = textField.text
        default: return
        }
    }
}

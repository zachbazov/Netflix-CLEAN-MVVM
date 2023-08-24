//
//  TextFieldDelegate.swift
//  netflix
//
//  Created by Developer on 22/08/2023.
//

import UIKit

// MARK: - TextFieldDelegate Type

protocol TextFieldDelegate: UITextFieldDelegate, UITextFieldValueObserving {}

// MARK: - UITextFieldValueObserving Type

protocol UITextFieldValueObserving {
    func valueDidChange(_ textField: UITextField)
}
